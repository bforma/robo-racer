/** @jsx React.DOM */
RoboRacer.Views.Registers = React.createBackboneClass({
  createRegister: function(register, index) {
    return new RoboRacer.Views.Register({
      key: index,
      index: index,
      model: register,
      onCardDrop: this.props.onCardDrop,
      onInstructionCardClick: function(event, instructionCard) {
        this.props.onInstructionCardInRegisterClick(
          event, instructionCard, index
        );
      }.bind(this)
    });
  },

  render: function() {
    return (
      <ol className="registers">
        { this.getCollection().map(this.createRegister) }
      </ol>
    );
  }
});
