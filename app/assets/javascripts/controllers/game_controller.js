RoboRacer.Controllers.GameController = Class.extend({
  initialize: function(game) {
    this.game = game;
  },

  show: function() {
    this.game.fetch();

    React.renderComponent(
      new RoboRacer.Views.Game({model: this.game}),
      $("#game").get(0)
    );
  }
});
