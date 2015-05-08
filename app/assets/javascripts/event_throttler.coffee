RoboRacer.EventThrottler = Class.extend({
  initialize: (gameEventListener) ->
    @gameEventListener = gameEventListener
    @queue = new (RoboRacer.Queue)
    return

  handleEvent: (event) ->
    delay = @constructor.EVENT_DELAYS[event.payload_type] or 0
    console.log 'Queueing %s with a delay of %i ms', event.payload_type, delay
    @queue.add (->
      @gameEventListener.handleEvent event
      return
    ).bind(this), delay
    return

}, {
  EVENT_DELAYS:
    'InstructionCardRevealedEvent': 250
    'RobotRotatedEvent': 2000
    'RobotMovedEvent': 2000
    'RobotPushedEvent': 2000
    'RobotDiedEvent': 2000
})
