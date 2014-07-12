RoboRacer.Collections.Opponents = Backbone.Collection.extend({
  model: RoboRacer.Models.Player,

  initialize: function() {
    this.on('add', this.opponentAdded, this);
  },

  addOpponent: function(playerId) {
    var player = new RoboRacer.Models.Player({_id: playerId});
    this.add(player);

    var index = this.indexOf(player);
    RoboRacer.Collections.Opponents.color(playerId, index);
  },

  opponentAdded: function(opponent) {
    opponent.fetch();
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
