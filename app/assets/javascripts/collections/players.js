RoboRacer.Collections.Players = Backbone.Collection.extend({
  model: RoboRacer.Models.Player,

  initialize: function() {
    this.on('add', this.playerAdded, this);

    RoboRacer.App.socket.on('player_joined_game_event', this.playerJoinedGame, this);
    RoboRacer.App.socket.on('player_left_game_event', this.playerLeftGame, this);
  },

  playerAdded: function(player) {
    player.fetch();

    this.constructor.color(player.id, this.indexOf(player));
  },

  playerJoinedGame: function(event) {
    this.add({_id: event.player_id});
  },

  playerLeftGame: function(event) {
    var player = this.findWhere({_id: event.player_id});
    this.remove(player);
  },

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
