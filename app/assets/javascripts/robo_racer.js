window.RoboRacer = {
  Models: {},
  Collections: {},
  Views: {},
  Controllers: {}
};

RoboRacer.App = Class.extend({
  initialize: function(accessToken, gameId) {
    this.socket = window.socket = new RoboRacer.Socket(accessToken, gameId);

    var game = new RoboRacer.Models.Game({_id: gameId});
    this.gameController = new RoboRacer.Controllers.GameController(game);
    this.gameController.show();
  }
});
