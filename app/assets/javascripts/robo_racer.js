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

    var gameRepository = new RoboRacer.GameRepository();
    var gameEventListener = new RoboRacer.GameEventListener(gameRepository);
    RoboRacer.App.socket = window.socket = new RoboRacer.Socket(
      gameEventListener,
      accessToken,
      gameId
    );

    $.get('/api/games/' + gameId + '/events', function(events) {
      gameEventListener.handleEvents(events);
      var game = window.game = gameRepository.find(gameId);
      game.set('current_player_id', currentPlayerId);

      React.renderComponent(
        new RoboRacer.Views.Game({model: game}),
        $("#game").get(0)
      );
    });
  }
});
