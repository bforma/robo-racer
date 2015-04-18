RoboRacer.Views.LobbyButtons = React.createBackboneClass({
  mixins: [
    React.BackboneMixin('game'),
    React.BackboneMixin({
      modelOrCollection: function(props) {
        return props.game.get('players');
      }
    })
  ],

  render: function() {
    var game = this.props.game;
    if (game.currentPlayerInGame()) {
      var helpText =
        <div>
          <h2>Joined game</h2>
          <p>You have joined the game. The host will start the game soon.</p>
          <p>Invite other players by sharing the following URL with them.</p>
          <p>{ window.location.href }</p>
        </div>
      var leaveGameButton = <button className="button inverted" onClick={this.leaveGame}>Leave game</button>
    } else {
      var helpText =
        <div>
          <h2>Join game</h2>
          <p>Join this game by clicking the button below.</p>
        </div>
      var joinGameButton = <button className="button" onClick={this.joinGame}>Join game</button>
    }

    if (game.currentPlayerIsHost()) {
      var helpText =
        <div>
          <h2>Host game</h2>
          <p>You are the host of this game. You can start the game whenever you like.</p>
          <p>Invite other players by sharing the following URL with them.</p>
          <p>{ window.location.href }</p>
        </div>
      var startGameButton =
        <button className="button" onClick={this.startGame}>Start game</button>
    }

    return (
      <div className="mod-lobby">
        <div>
          { helpText }
          { joinGameButton }
          { startGameButton }
          { leaveGameButton }
        </div>
      </div>
    );
  },

  joinGame: function() {
    this.props.game.join();
  },

  leaveGame: function() {
    this.props.game.leave({success: function() {
      document.location.href = '/';
    }});
  },

  startGame: function() {
    this.props.game.start();
  }
});
