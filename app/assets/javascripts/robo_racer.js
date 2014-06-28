window.RoboRacer = {
  Models: {},
  Views: {}
};

RoboRacer.App = Class.extend({
  initialize: function(accessToken, gameId) {
    this.socket = window.socket = new RoboRacer.Socket(accessToken, gameId);

    React.renderComponent(
      new RoboRacer.Views.Game(),
      document.body
    );
  }
});
