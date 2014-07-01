class GameEventListener < BaseEventListener

  inheritable_accessor :router do
    Fountain::Router.create_router
  end

  route GameCreatedEvent do |event|
    Game.create!(
      _id: event.id,
      state: event.state,
      host_id: event.host_id,
      player_ids: []
    )
  end

  route PlayerJoinedGameEvent do |event|
    game = Game.find(event.id)
    game.push(player_ids: event.player_id)
  end

  route PlayerLeftGameEvent do |event|
    game = Game.find(event.id)
    game.pull(player_ids: event.player_id)
  end
end
