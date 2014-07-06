/** @jsx React.DOM */
RoboRacer.Views.Program = React.createBackboneClass({
  render: function() {
    var registers = RoboRacer.Views.Registers({
      collection: this.getCollection(),
      onCardDrop: this.props.onCardDrop,
      onInstructionCardInRegisterClick: this.props.onInstructionCardInRegisterClick
    });

    var enabled = _.every(this.getCollection().models, function(register) {
      return register.get('instruction_card');
    });

    return (
      <div className="program">
        { registers }

        <button
          className="button"
          disabled={ !enabled }
          onClick={ this.props.onProgramRobotClick }>
          Program robot
        </button>
      </div>
    );
  }
});
