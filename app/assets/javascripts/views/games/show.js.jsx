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
      <div className="mod-game">
        <div className="viewport">
          <header>{ game.get('state') }</header>

          <div className="body">
            <div className="left">
              { RoboRacer.Views.Opponents({collection: game.get('opponents')}) }
            </div>

            <div className="right">
              { joinGameButton }
              { leaveGameButton }
              { startGameButton }

              <div className="table">
                { board }
                { hand }
              </div>

              { program }
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
