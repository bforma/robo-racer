RoboRacer.Models.Game = Backbone.Model.extend({
  idAttribute: "_id",
  urlRoot: "/api/games",
  defaults: {
    player_ids: [],
    opponents: new RoboRacer.Collections.Opponents()
  },

  initialize: function() {
    this.on("change:player_ids", this.updateOpponents);
  },

  updateOpponents: function() {
    var allPlayers = this.get('player_ids');
    allPlayers.forEach(function(player_id) {
      var player = new RoboRacer.Models.Player({_id: player_id});
      player.fetch();
      this.get('opponents').add(player)
    }.bind(this));
  }
});
