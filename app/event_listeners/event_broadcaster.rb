class EventBroadcaster < BaseEventListener
  GAME_CHANNEL_FORMAT = "robo_racer.%s.games.%s"

  inheritable_accessor :router do
    Fountain::Router.create_router
  end

  route(PlayerJoinedGameEvent) { |event| publish(event) }
  route(PlayerLeftGameEvent) { |event| publish(event) }

  route(GameStartedEvent) do |event|
    publish(event, ->(payload) do
      attributes = payload.to_h
      instruction_deck = attributes.delete(:instruction_deck)
      attributes.merge(instruction_deck_size: instruction_deck.size)
    end)
  end

private
  
  def redis
    Redis.new(
      host: Redis::Configuration.host,
      port: Redis::Configuration.port,
      db: Redis::Configuration.db # although ignored by pub/sub
    )
  end

  def publish(event, payload_filter = ->(payload) { payload })
    channel = format(GAME_CHANNEL_FORMAT, Rails.env, event.id)
    redis.publish(channel, {
      type: event.class.to_s.underscore,
      payload: payload_filter.call(event)
    }.to_json)
  end

end
