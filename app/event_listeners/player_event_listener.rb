class PlayerEventListener < BaseEventListener
  inheritable_accessor :router do
    Fountain::Router.create_router
  end

  route PlayerCreatedEvent do |event|
    Player.transaction do
      player = Player.create!(
        id: event.id,
        name: event.name,
        email: event.email,
        access_token: event.access_token
      )
      player.update_column(:encrypted_password, event.password)
    end
  end
end
