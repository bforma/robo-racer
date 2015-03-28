RoboRacer.Views.Registers = React.createBackboneClass({
  createRegister: function(register, index) {
    var func = function(event, instructionCard) {
      this.props.onInstructionCardClick(
        event, instructionCard, index
      );
    }.bind(this);

    return <RoboRacer.Views.Register
      key={index}
      index={index}
      model={register}
      onCardDrop={this.props.onCardDrop}
      onInstructionCardClick={func}
    />
  },

  render: function() {
    return (
      <ol className="registers">
        { this.getCollection().map(this.createRegister) }
      </ol>
    );
  }
});
