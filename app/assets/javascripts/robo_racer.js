window.RoboRacer = {
  Models: {},
  Collections: {},
  Views: {},
  Controllers: {}
};

RoboRacer.App = Class.extend({
  initialize: function(currentPlayerId, accessToken, gameId) {
    // add access_token to all AJAX requests
    $.ajaxSetup({data: {access_token: accessToken}});

    this.socket = window.socket = new RoboRacer.Socket(accessToken, gameId);

    var game = new RoboRacer.Models.Game({
      _id: gameId,
      currentPlayerId: currentPlayerId
    });
    this.gameController = new RoboRacer.Controllers.GameController(game);
    this.gameController.show();
  }
});
