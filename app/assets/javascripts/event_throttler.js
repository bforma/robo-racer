RoboRacer.EventThrottler = Class.extend({
  initialize: function(gameEventListener) {
    this.gameEventListener = gameEventListener;
    this.queue = new RoboRacer.Queue();
  },

  handleEvent: function(event) {
    var delay = this.constructor.EVENT_DELAYS[event.payload_type] || 0;
    console.log('Queueing %s with a delay of %i ms', event.payload_type, delay);
    this.queue.add(function() {
      this.gameEventListener.handleEvent(event);
    }.bind(this), delay);
  },
}, {
  EVENT_DELAYS: {
    'RobotRotatedEvent': 1000,
    'RobotMovedEvent': 1000,
    'RobotPushedEvent': 1000,
    'RobotDiedEvent': 1000,
  }
});
