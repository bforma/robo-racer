class PlayerEventListener < BaseEventListener

  inheritable_accessor :router do
    Fountain::Router.create_router
  end

  route PlayerCreatedEvent do |event|
    player = Player.create(
      _id: event.id,
      name: event.name,
      email: event.email,
      encrypted_password: event.password,
      access_token: event.access_token
    )
    player.save(validate: false)
  end
end
