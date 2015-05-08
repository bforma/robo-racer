RoboRacer.EventThrottler = Class.extend({
  initialize: (gameEventListener) ->
    @gameEventListener = gameEventListener
    @queue = new (RoboRacer.Queue)

  handleEvent: (event) ->
    delay = @constructor.EVENT_DELAYS[event.payload_type] or 0
    console.log 'Queueing %s with a delay of %i ms', event.payload_type, delay
    @queue.add (->
      @gameEventListener.handleEvent event
    ).bind(this), delay

}, {
  EVENT_DELAYS:
    'InstructionCardRevealedEvent': 250
    'RobotRotatedEvent': 1500
    'RobotMovedEvent': 1500
    'RobotPushedEvent': 1500
    'RobotDiedEvent': 1500
})
