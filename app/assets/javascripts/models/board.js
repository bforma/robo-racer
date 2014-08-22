RoboRacer.Models.Board = Backbone.Model.extend({
  initialize: function() {
    this.set('tiles', new RoboRacer.Collections.Tiles());
    this.set('spawns', new RoboRacer.Collections.Spawns());
    this.set('checkpoints', new RoboRacer.Collections.Checkpoints());
    this.set('robots', new RoboRacer.Collections.Robots());
  }
});
