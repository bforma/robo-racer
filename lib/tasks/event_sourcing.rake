namespace :es do
  desc "Drops all recorded events and the current view model"
  task drop: ["environment", "db:mongoid:purge"] do
    gateway = RoboRacer::Gateway.build
    gateway.event_store.clear
  end

  desc "Drops the current view model and replays all recorded events to build a new one"
  task replay: ["environment", "db:mongoid:purge"] do
    started_at = Time.current
    gateway = RoboRacer::Gateway.build(
      event_listeners: RoboRacer::Gateway::REPLAYABLE
    )
    n = 0
    gateway.event_store.each_event do |event|
      gateway.event_bus.publish(event)
      n += 1
    end
    ended_at = Time.current

    puts "Replayed #{n} events in #{((ended_at - started_at) * 1000).to_i}ms"
  end
end

module Fountain
  module EventStore
    class RedisEventStore < EventStore
      def clear
        @connection_pool.with do |redis|
          redis.flushall
        end
      end

      def each_event
        # poor man's implementation for iterating over all events
        @connection_pool.with do |redis|
          aggregates = redis.keys("stream:*")
          aggregates.each do |aggregate|
            redis.lrange(aggregate, 0, -1).each do |serialized_event|
              yield(deserialize(serialized_event))
            end
          end
        end
      end
    end
  end
end

