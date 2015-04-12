RoboRacer.Views.Game = React.createBackboneClass({
  render: function() {
    var game = this.getModel();
    return (
      <div className="mod-game">
        <div className="column left">
          <div className="row top">
            <h3>Players</h3>
            <RoboRacer.Views.Players collection={game.get('players')} />
          </div>
          <div className="row">
            <h3>Hand</h3>
            <RoboRacer.Views.Hand player={game.currentPlayer()} />
          </div>
        </div>
        <div className="column right">
          <div className="row top">
            <RoboRacer.Views.Board model={game.get('board')} />
          </div>
          <div className="row">
            <h3>Program</h3>
            <RoboRacer.Views.Program
              player={game.currentPlayer()}
              onProgramRobotClick={this.programRobot}
            />
          </div>
        </div>
      </div>
    );
  },

  programRobot: function() {
    this.getModel().programRobot();
  }
});
