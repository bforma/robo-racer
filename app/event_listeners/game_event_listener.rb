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
      y: event.robot.y
    ))
  end

  route GameRoundStartedEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    game.update_attributes!(round_number: event.game_round.number)
  end

  route InstructionCardDealtEvent do |event|
    game = Projections::Mongo::Game.find(event.id)
    hand = game.hands.where(player_id: event.player_id).first_or_initialize
    hand.instruction_cards.push(Projections::Mongo::InstructionCard.new(
      action: event.instruction_card.action,
      amount: event.instruction_card.amount,
      priority: event.instruction_card.priority
    ))
    hand.save!
  end
end
