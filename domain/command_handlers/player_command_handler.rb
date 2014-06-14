class PlayerCommandHandler < BaseCommandHandler
  route CreatePlayer do |command|
    player = PlayerAggregate.new(
      command.id,
      command.name,
      command.email,
      command.password
    )
    repository.add(player)
  end
end
