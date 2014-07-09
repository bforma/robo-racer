RoboRacer.Collections.Robots = Backbone.Collection.extend({
  model: RoboRacer.Models.Robot,

  initialize: function() {
    RoboRacer.App.socket.on('robot_spawned_event', this.robotSpawned, this);
    RoboRacer.App.socket.on('robot_died_event', this.robotDied, this);
  },

  robotSpawned: function(event) {
    this.add(new RoboRacer.Models.Robot({
      player_id: event.player_id,
      x: event.robot.x,
      y: event.robot.y,
      facing: event.robot.facing
    }));
  },

  robotDied: function(event) {
    var robot = this.findWhere({player_id: event.player_id});
    this.remove(robot);
  }
});
