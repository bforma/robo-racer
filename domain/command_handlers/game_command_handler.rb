module RoboRacer
  module CommandHandlers
    class Game < Base
      route CreateGameCommand do |command|
        game = Aggregates::GameAggregate.new(command.id)
        repository.add(game)
      end

      route MoveRobotCommand do |command|
        game = repository.load(command.id)
        game.move_robot(command.speed)
      end
    end
  end
end
