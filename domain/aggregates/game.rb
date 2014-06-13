module RoboRacer
  module Aggregates
    class Game < Base
      def initialize(id)
        apply GameCreatedEvent.new(id)
      end

      def move_robot(speed)
        apply RobotMovedEvent.new(id, @robot.move(speed))
      end

      route_event GameCreatedEvent do |event|
        @id = event.id
        @robot = GameUnit.new(0, 0, GameUnit::RIGHT)
      end
    end
  end
end

