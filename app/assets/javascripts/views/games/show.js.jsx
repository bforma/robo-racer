/** @jsx React.DOM */
RoboRacer.Views.Game = React.createBackboneClass({
  render: function() {
    var game = this.getModel();

    if(game.lobbying()) {
      var lobbyButtons = <RoboRacer.Views.LobbyButtons game={game} />
    } else if(game.running()) {
      var round = "Round " + game.get('round_number');
      var board = RoboRacer.Views.Board({model: game.get('board')});
      var hand = <RoboRacer.Views.Hand
        collection={game.currentPlayer().get('hand')}
        onInstructionCardInHandClick={this.onInstructionCardInHandClick}
      />;
      var program = <RoboRacer.Views.Program
        collection={game.currentPlayer().get('program')}
        onCardDrop={this.onCardDrop}
        onProgramRobotClick={this.programRobot}
        onInstructionCardInRegisterClick={this.onInstructionCardInRegisterClick}
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
