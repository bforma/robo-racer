class GameEventListener < BaseEventListener
  include Converters::ValueObject

  inheritable_accessor :router do
    Fountain::Router.create_router
  end

  route GameCreatedEvent do |event|
    Projections::Mongo::Game.create!(
      _id: event.id,
      state: event.state,
      host_id: event.host_id
    )
  end

  route PlayerJoinedGameEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    game.players.build(player_id: event.player_id)
    game.save!
  end

  route PlayerLeftGameEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    game.players.where(player_id: event.player_id).delete_all
    game.save!
  end

  route GameStartedEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    tiles = event.tiles.map { |_, tile| to_model(tile) }
    game.update_attributes!(
      state: event.state,
      board: Projections::Mongo::Board.new(tiles: tiles),
      instruction_deck_size: event.instruction_deck.size
    )
  end

  route SpawnPlacedEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    game.board.spawns.push(Projections::Mongo::Spawn.new(
      player_id: event.player_id,
      x: event.spawn.x,
      y: event.spawn.y,
      facing: event.spawn.facing
    ))
  end

  route GoalPlacedEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    game.board.checkpoints.push(Projections::Mongo::Checkpoint.new(
      x: event.goal.x,
      y: event.goal.y,
      priority: event.goal.priority
    ))
  end

  route RobotSpawnedEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    game.board.robots.push(Projections::Mongo::Robot.new(
      player_id: event.player_id,
      x: event.robot.x,
      y: event.robot.y,
      facing: event.robot.facing
    ))
  end

  route GameRoundStartedEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    game.round_number = event.game_round.number

    event.hands.each do |player_id, instruction_cards|
      player = game.players.where(player_id: player_id).first
      player.hand.instruction_cards = instruction_cards
      player.program.instruction_cards = instruction_cards
    end

    game.save!
  end

  route InstructionCardDealtEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    hand = game.players.where(player_id: event.player_id).first.hand
    hand.instruction_cards.push(to_model(event.instruction_card))
  end

  route RobotProgrammedEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    player = game.players.where(player_id: event.player_id).first
    instruction_cards = to_models(event.instruction_cards)

    player.hand.instruction_cards.
      any_in(priority: instruction_cards.map(&:priority)).
      delete_all

    instruction_cards.each do |instruction_card|
      player.program.instruction_cards = instruction_cards
    end

    game.save!
  end

  move_robot = Proc.new do |event|
    game = Projections::Mongo::Game.find(event.id)
    game.board.robots.
      where(player_id: event.player_id).
      update(x: event.robot.x, y: event.robot.y)
  end

  route RobotMovedEvent, &move_robot
  route RobotPushedEvent, &move_robot

  route RobotRotatedEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    game.board.robots.
      where(player_id: event.player_id).
      update(facing: event.robot.facing)
  end

  route RobotDiedEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    game.board.robots.where(player_id: event.player_id).delete_all
  end
end
