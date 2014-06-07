module RoboRacer
  module CommandHandlers
    class Player < Base
      route CreatePlayer do |command|
        player = Aggregates::Player.new(
          command.id,
          command.name,
          command.password
        )
        repository.add(player)
      end
    end
  end
end
