RoboRacer.Queue = Class.extend({
  initialize: function() {
    this.queue = new Array();
    this.timeoutId = undefined;
  },

  add: function(func, delay) {
    this.queue.push({func: func, delay: delay || 0});
    this.start();
  },

  start: function() {
    if(this.hasItems() && !this.timeoutId) {
      (function loop() {
        this.stop();
        var next = this.queue.splice(0, 1)[0];
        if(next) {
          this.timeoutId = setTimeout(function() {
            next.func();
            loop.bind(this)();
          }.bind(this), next.delay);
        }
      }.bind(this))();
    }
  },

  stop: function() {
    if(this.timeoutId !== undefined) {
      clearTimeout(this.timeoutId);
      this.timeoutId = undefined;
    }
  },

  hasItems: function() {
    return _.any(this.queue);
  }
});
