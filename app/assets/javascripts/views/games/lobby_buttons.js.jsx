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
      var leaveGameButton = <button className="button" onClick={this.leaveGame}>Leave game</button>
    } else {
      var joinGameButton = <button className="button" onClick={this.joinGame}>Join game</button>
    }

    if (game.currentPlayerIsHost()) {
      var startGameButton =
        <button className="button" onClick={this.startGame}>Start game</button>
    }

    return (
      <div>
        { joinGameButton }
        { leaveGameButton }
        { startGameButton }
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
