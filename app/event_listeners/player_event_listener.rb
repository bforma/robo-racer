class PlayerEventListener
  include Fountain::Event::Listener

  route PlayerCreated do |event|
    player = Player.create(
      _id: event.id,
      name: event.name,
      email: event.email,
      encrypted_password: event.password
    )
    player.save(validate: false)
  end
end
