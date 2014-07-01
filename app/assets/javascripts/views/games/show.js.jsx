/** @jsx React.DOM */
RoboRacer.Views.Game = React.createBackboneClass({
  changeOptions: "change change:player_ids",

  render: function() {
    var game = this.getModel();
    if (game.currentPlayerInGame()) {
      var leaveGameButton = RoboRacer.Views.LeaveGame({onClick: this.leaveGame});
    } else {
      var joinGameButton = RoboRacer.Views.JoinGame({onClick: this.joinGame});
    }

    return (
      <div className="mod-game">
        <div className="viewport">
          <div className="body">
            <div className="left">
              { RoboRacer.Views.Opponents({collection: game.get('opponents')}) }
            </div>

            <div className="right">
              { joinGameButton }
              { leaveGameButton }
            </div>
          </div>
        </div>
      </div>
    );
  },

  joinGame: function() {
    this.getModel().join();
  },

  leaveGame: function() {
    this.getModel().leave();
    document.location.href = "/";
  }
});
