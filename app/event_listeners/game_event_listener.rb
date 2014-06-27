class GameEventListener < BaseEventListener

  inheritable_accessor :router do
    Fountain::Router.create_router
  end

  route GameCreatedEvent do |event|
    Game.create!(
      _id: event.id,
      state: event.state,
      host_id: event.host_id
    )
  end
end
