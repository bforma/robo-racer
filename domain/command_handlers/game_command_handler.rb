class GameCommandHandler < BaseCommandHandler
  route CreateGameCommand do |command|
    game = GameAggregate.new(command.id)
    repository.add(game)
  end

  route MoveRobotCommand do |command|
    game = repository.load(command.id)
    game.move_robot(command.speed)
  end
end
