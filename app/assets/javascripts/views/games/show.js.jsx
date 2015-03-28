RoboRacer.Views.Game = React.createBackboneClass({
  render: function() {
    var game = this.getModel();

    if(game.lobbying()) {
      var lobbyButtons = <RoboRacer.Views.LobbyButtons game={game} />
    } else if(game.running()) {
      var round = "Round " + game.get('round_number');
      var board = <RoboRacer.Views.Board model={game.get('board')} />;
      var hand = <RoboRacer.Views.Hand player={game.currentPlayer()} />;
      var program = <RoboRacer.Views.Program
        player={game.currentPlayer()}
        onProgramRobotClick={this.programRobot}
      />;
    }

    return (
      <div className="layout-game">
        <div className="body">
          { board }
        </div>

        <RoboRacer.Views.SidePanel orientation="left">
          <div className="mod-game_state">
            <p>Game is { game.get('state') }</p>
            <p>{ round }</p>
          </div>
          <RoboRacer.Views.Players collection={game.get('players')} />
        </RoboRacer.Views.SidePanel>

        <RoboRacer.Views.SidePanel orientation="right">
          {lobbyButtons}
          {hand}
        </RoboRacer.Views.SidePanel>

        <RoboRacer.Views.SidePanel orientation="bottom">
          {program}
        </RoboRacer.Views.SidePanel>
      </div>
    );
  },

  programRobot: function() {
    this.getModel().programRobot();
  }
});
