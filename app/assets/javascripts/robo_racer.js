window.RoboRacer = {
  Models: {},
  Views: {}
};

RoboRacer.App = Class.extend({
  initialize: function() {
    React.renderComponent(
      new RoboRacer.Views.Game(),
      document.body
    );
  }
});
