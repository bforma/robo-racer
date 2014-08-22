RoboRacer.Collections.Players = Backbone.Collection.extend({
  model: RoboRacer.Models.Player,

  initialize: function() {
    this.on('add', this.playerAdded, this);
  },

  playerAdded: function(player) {
    player.fetch();

    this.constructor.color(player.id, this.indexOf(player));
  }
}, {
  COLORS: [
    "red",
    "yellow",
    "orange",
    "pink",
    "green",
    "brown",
    "grey",
    "lightblue"
  ],

  playerIdToColor: {},

  color: function(playerId, index) {
    if (index !== undefined) {
      this.playerIdToColor[playerId] = this.COLORS[index];
    } else {
      return this.playerIdToColor[playerId];
    }
  }
});
