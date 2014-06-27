require Rails.root + 'domain/domain'

Fountain.configure do |config|
  config.logger = Logger.new($stdout)
  config.logger.level = Logger::INFO
end

module RoboRacer
  class Gateway
    class << self
      def build
        new(
          Fountain::EventStore::RedisEventStore.build,
          [
            PlayerEventListener.new,
            GameEventListener.new
          ]
        )
      end
    end

    def command_callback
      @command_callback ||= DefaultCommandCallback.new(Rails.logger)
    end
  end
end
