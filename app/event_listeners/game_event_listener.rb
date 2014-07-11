class GameEventListener < BaseEventListener
  include Converters::ValueObject

  inheritable_accessor :router do
    Fountain::Router.create_router
  end

  route GameCreatedEvent do |event|
    Projections::Mongo::Game.create!(
      _id: event.id,
      state: event.state,
      host_id: event.host_id,
      player_ids: []
    )
  end

  route PlayerJoinedGameEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    game.push(player_ids: event.player_id)
  end

  route PlayerLeftGameEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    game.pull(player_ids: event.player_id)
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
    game.update_attributes!(
      round_number: event.game_round.number,
      hands: [],
      programs: []
    )
  end

  route InstructionCardDealtEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    hand = game.hands.where(player_id: event.player_id).first_or_initialize
    hand.instruction_cards.build(to_model(event.instruction_card).attributes)
    hand.save!
  end

  route RobotProgrammedEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    instruction_cards = to_models(event.instruction_cards)

    # TODO wrap in transaction
    hand = game.hands.where(player_id: event.player_id).first
    hand.instruction_cards.
      any_in(priority: event.instruction_cards.map(&:priority)).
      delete_all
    hand.save!

    program = game.programs.where(player_id: event.player_id).first_or_initialize
    instruction_cards.each do |instruction_card|
      program.instruction_cards.build(instruction_card.attributes)
    end
    program.save!
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
