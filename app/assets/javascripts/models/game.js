RoboRacer.Models.Game = Backbone.Model.extend({
  idAttribute: "_id",
  urlRoot: "/api/games",
  defaults: {
    opponents: new RoboRacer.Collections.Opponents()
  },

  initialize: function() {
    RoboRacer.App.socket.on("player_joined_game_event", this.playerJoinedGame, this);
    RoboRacer.App.socket.on("player_left_game_event", this.playerLeftGame, this);

    // player_ids change after .fetch()
    this.on("change:player_ids", function() {
      _.each(this.get('player_ids'), function(player_id) {
        if (player_id != this.get('current_player_id')) {
          this.addOpponent(player_id);
        }
      }.bind(this));
    }.bind(this));
  },

  currentPlayerInGame: function() {
    return _.include(this.get('player_ids'), this.get("current_player_id"));
  },

  join: function() {
    this.execute("join");
  },

  leave: function() {
    this.execute("leave");
  },

  execute: function(command) {
    $.ajax({
      url: this.url() + "/" + command,
      type: 'PUT'
    });
  },

  playerJoinedGame: function(event) {
    this.get('player_ids').push(event.player_id);
    if(event.player_id !== this.get('current_player_id')) {
      this.addOpponent(event.player_id)
    }
    this.trigger('change:player_ids');
  },

  playerLeftGame: function(event) {
    _.remove(this.get('player_ids'), function(player_id) {
      return player_id == event.player_id;
    });
    if(event.player_id !== this.get('current_player_id')) {
      this.removeOpponent(event.player_id);
    }
    this.trigger('change:player_ids');
  },

  addOpponent: function(player_id) {
    var player = new RoboRacer.Models.Player({_id: player_id});
    player.fetch();
    this.get('opponents').add(player);
  },

  removeOpponent: function(player_id) {
    this.get('opponents').remove(
      new RoboRacer.Models.Player({_id: player_id})
    );
  }
});
