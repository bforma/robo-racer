module RoboRacer
  module Aggregates
    class PlayerAggregate < Base
      def initialize(id, name, email, password)
        apply PlayerCreated.new(id, name, email, password)
      end

      route_event PlayerCreated do |event|
        @id = event.id
      end
    end
  end
end
