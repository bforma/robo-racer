RoboRacer.Models.Game = Backbone.Model.extend({
  idAttribute: "_id",
  urlRoot: "/api/games",
  defaults: {
    opponents: new RoboRacer.Collections.Opponents()
  },

  initialize: function() {
    this.on("change:player_ids", this.updateOpponents);
  },

  updateOpponents: function() {
    _.each(this.get('player_ids'), function(player_id) {
      if (player_id != this.get('currentPlayerId')) {
        var player = new RoboRacer.Models.Player({_id: player_id});
        this.get('opponents').add(player);
        player.fetch();
      }
    }.bind(this));
  }
});
