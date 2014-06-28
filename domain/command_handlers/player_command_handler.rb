class PlayerCommandHandler < BaseCommandHandler
  route CreatePlayerCommand do |command|
    player = PlayerAggregate.new(
      command.id,
      command.name,
      command.email,
      command.password,
      command.access_token
    )
    repository.add(player)
  end
end
