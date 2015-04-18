RoboRacer.Views.Show = React.createBackboneClass({
  render: function() {
    var game = this.getModel();
    if(game.lobbying()) {
      return <RoboRacer.Views.Lobby model={game} />
    } else if(game.running()) {
      return <RoboRacer.Views.Game model={game} />;
    }
  }
});
