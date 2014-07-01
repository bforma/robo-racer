class EventBroadcaster < BaseEventListener
  GAME_CHANNEL_FORMAT = "robo_racer.%s.games.%s"

  inheritable_accessor :router do
    Fountain::Router.create_router
  end

  route PlayerJoinedGameEvent do |event|
    publish(event)
  end

  route PlayerLeftGameEvent do |event|
    publish(event)
  end

private
  
  def redis
    Redis.new(
      host: Redis::Configuration.host,
      port: Redis::Configuration.port,
      db: Redis::Configuration.db # although ignored by pub/sub
    )
  end

  def publish(event)
    channel = format(GAME_CHANNEL_FORMAT, Rails.env, event.id)
    redis.publish(channel, {
      type: event.class.to_s.underscore,
      payload: event
    }.to_json)
  end

end
