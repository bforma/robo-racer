RoboRacer.GameRepository = Class.extend({
  games: {},

  add: function(game) {
    this.games[game.id] = game;
  },

  find: function(id) {
    var game = this.games[id];
    if(game === undefined) {
      throw new Error('No game found for id "' + id + '"');
    }
    return game;
  }
});

