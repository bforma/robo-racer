class EventBroadcaster < BaseEventListener
  GAME_CHANNEL_FORMAT = "robo_racer.%s.games.%s"

  UNFILTERED_EVENTS = [
    PlayerJoinedGame,
    PlayerLeftGame,
    GameRoundStarted,
    SpawnPlaced,
    GoalPlaced,
    RobotSpawned,
    InstructionCardDealt, # TODO filter cards
    RobotProgrammed, # TODO filter cards
    AllRobotsProgrammed,
    GameRoundStartedPlaying,
    InstructionCardRevealed,
    RobotMoved,
    RobotRotated,
    RobotPushed,
    RobotDied,
    GoalTouched,
    GameRoundFinishedPlaying,
    PlayerWonGame,
    GameEnded,
  ]

  inheritable_accessor :router do
    Fountain::Router.create_router
  end

  UNFILTERED_EVENTS.each do |event_class|
    route(event_class) { |event| publish(event) }
  end

  route(GameStarted) do |event|
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
      payload_type: event.class.name,
      payload: payload_filter.call(event)
    }.to_json)
  end
end
