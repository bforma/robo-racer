module RoboRacer
  module Aggregates
    class Player < Base
      def initialize(id, name, password)
        apply PlayerCreated.new(id, name, password)
      end
    end
  end
end
