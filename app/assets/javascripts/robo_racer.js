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

    RoboRacer.App.socket = window.socket = new RoboRacer.Socket(accessToken, gameId);

    var game = window.game = new RoboRacer.Models.Game({
      _id: gameId,
      current_player_id: currentPlayerId
    });

    // TODO perhaps render game state inline in games/show.html.haml?
    game.fetch({success: function() {
      React.renderComponent(
        new RoboRacer.Views.Game({model: game}),
        $("#game").get(0)
      );
    }});
  }
});
