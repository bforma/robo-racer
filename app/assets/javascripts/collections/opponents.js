RoboRacer.Collections.Opponents = Backbone.Collection.extend({
  model: RoboRacer.Models.Player,

  initialize: function() {
    this.on('add', this.opponentAdded, this);
  },

  opponentAdded: function(opponent) {
    opponent.fetch();
  }
});
