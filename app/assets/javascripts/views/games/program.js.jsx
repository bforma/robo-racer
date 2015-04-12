RoboRacer.Views.Program = React.createBackboneClass({
  mixins: [
    React.BackboneMixin('player'),
    React.BackboneMixin({
      modelOrCollection: function(props) {
        return props.player.get('program');
      }
    })
  ],

  render: function() {
    var goButtonEnabled =
      this.props.player.get('program').allRegistersFilled() &&
      ! this.props.player.hasCommittedProgram();

    return (
      <div className="mod-program">
        <RoboRacer.Views.Registers
          collection={this.props.player.get('program')}
          onCardDrop={this.onCardDrop}
          onInstructionCardClick={this.onInstructionCardClick}
        />

        <button
          className="button"
          disabled={ ! goButtonEnabled}
          onClick={this.props.onProgramRobotClick}>
          Program robot
        </button>
      </div>
    );
  },

  onCardDrop: function(registerIndex, instructionCard) {
    this.props.player.programRegister(registerIndex, instructionCard);
  },

  onInstructionCardClick: function(event, instructionCard, registerIndex) {
    this.props.player.unprogramRegister(registerIndex, instructionCard);
  }
});
