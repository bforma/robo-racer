RoboRacer.Views.Lobby = React.createBackboneClass({
  render: function() {
    var game = this.getModel();
    return (
      <div className="mod-game">
        <div className="column left">
          <div className="row top">
            <h3>Players</h3>
            <RoboRacer.Views.Players collection={game.get('players')} />
          </div>
        </div>
        <div className="column right">
          <div className="row center">
            <RoboRacer.Views.LobbyButtons game={game} />
          </div>
        </div>
      </div>
    );
  }
});
