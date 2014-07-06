require Rails.root + 'domain/domain'

Fountain.configure do |config|
  config.logger = Logger.new($stdout)
  config.logger.level = Logger::INFO
end

module RoboRacer
  class Gateway
    DEFAULT_EVENT_STORE = Fountain::EventStore::RedisEventStore.build do |builder|
      builder.connection_pool = ::ConnectionPool.new do
        ::Redis.new(
          host: Redis::Configuration.host,
          port: Redis::Configuration.port,
          db: Redis::Configuration.db,
        )
      end
    end

    REPLAYABLE = [
      PlayerEventListener.new,
      GameEventListener.new,
    ]

    NON_REPLAYABLE = [
      AsyncEventListener.new,
      EventBroadcaster.new
    ]

    DEFAULT_EVENT_LISTENERS = REPLAYABLE + NON_REPLAYABLE

    class << self
      def build(opts = {})
        event_store = opts.fetch(:event_store, DEFAULT_EVENT_STORE)
        event_listeners = opts.fetch(:event_listeners, DEFAULT_EVENT_LISTENERS)

        new(event_store, event_listeners)
      end
    end

    def command_callback
      @command_callback ||= DefaultCommandCallback.new(Rails.logger)
    end
  end
end
