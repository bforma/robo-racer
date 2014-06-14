module RoboRacer
  module CommandHandlers
    class Base
      include Fountain::Command::Handler

      attr_reader :repository

      def initialize(repository)
        @repository = repository
      end
    end
  end
end
