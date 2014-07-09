RoboRacer.Models.Robot = Backbone.Model.extend({
  initialize: function() {
    RoboRacer.App.socket.on('robot_moved_event', this.moved, this);
    RoboRacer.App.socket.on('robot_pushed_event', this.moved, this);
    RoboRacer.App.socket.on('robot_rotated_event', this.rotated, this);
  },

  moved: function(event) {
    if (this.get('player_id') === event.player_id) {
      this.set({x: event.robot.x, y: event.robot.y});
    }
  },

  rotated: function(event) {
    if (this.get('player_id') === event.player_id) {
      this.set({facing: event.robot.facing});
    }
  }
});
