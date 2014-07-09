RoboRacer.Models.Board = Backbone.Model.extend({
  initialize: function() {
    this.set('tiles', new RoboRacer.Collections.Tiles());
    this.set('spawns', new RoboRacer.Collections.Spawns());
    this.set('checkpoints', new RoboRacer.Collections.Checkpoints());
    this.set('robots', new RoboRacer.Collections.Robots());

    RoboRacer.App.socket.on('spawn_placed_event', this.spawnPlaced, this);
    RoboRacer.App.socket.on('goal_placed_event', this.checkpointPlaced, this);
  },

  spawnPlaced: function(event) {
    this.get('spawns').add(new RoboRacer.Models.Spawn({
      player_id: event.player_id,
      x: event.spawn.x,
      y: event.spawn.y,
      facing: event.spawn.facing
    }));
  },

  checkpointPlaced: function(event) {
    this.get('checkpoints').add(new RoboRacer.Models.Checkpoint(event.goal));
  }
});
