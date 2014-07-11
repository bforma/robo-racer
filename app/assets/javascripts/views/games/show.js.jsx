/** @jsx React.DOM */
RoboRacer.Views.Game = React.createBackboneClass({
  changeOptions: "change change:player_ids",

  render: function() {
    var game = this.getModel();

    if(game.lobbying()) {
      if (game.currentPlayerInGame()) {
        var leaveGameButton = RoboRacer.Views.LeaveGame({onClick: this.leaveGame});
      } else {
        var joinGameButton = RoboRacer.Views.JoinGame({onClick: this.joinGame});
      }

      if (game.currentPlayerIsHost()) {
        var startGameButton =
          <button className="button" onClick={ this.startGame }>Start game</button>
      }
    } else if(game.running()) {
      var round = "Round " + game.get('round_number');
      var board = RoboRacer.Views.Board({model: game.get('board')});
      var hand = RoboRacer.Views.Hand({
        collection: game.get('hand'),
        onInstructionCardInHandClick: this.onInstructionCardInHandClick
      });
      var program = RoboRacer.Views.Program({
        collection: game.get('registers'),
        onCardDrop: this.onCardDrop,
        onProgramRobotClick: this.programRobot,
        onInstructionCardInRegisterClick: this.onInstructionCardInRegisterClick
      });
    }

    return (
      <div className="layout-game">
        <div className="body">
          { board }
        </div>

        <div className="panel left">
          <div className="content">
            <div className="mod-game_state">
              <p>Game is { game.get('state') }</p>
              <p>{ round }</p>
            </div>
            { RoboRacer.Views.Opponents({collection: game.get('opponents')}) }
          </div>
        </div>

        <div className="panel right">
          <div className="content">
            { joinGameButton }
            { leaveGameButton }
            { startGameButton }

            { hand }
          </div>
        </div>

        <div className="panel bottom">
          <div className="content">
            { program }
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
  },

  startGame: function() {
    this.getModel().start();
  },

  onCardDrop: function(registerIndex, instructionCard) {
    this.getModel().programRegister(registerIndex, instructionCard);
  },

  onInstructionCardInHandClick: function(event, instructionCard) {
    this.getModel().programNextEmptyRegister(instructionCard);
  },

  onInstructionCardInRegisterClick: function(event, instructionCard, registerIndex) {
    this.getModel().unprogramRegister(registerIndex, instructionCard);
  },

  programRobot: function() {
    this.getModel().programRobot();
  }
});
