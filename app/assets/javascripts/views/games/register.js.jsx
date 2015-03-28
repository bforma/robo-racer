RoboRacer.Views.Register = React.createBackboneClass({
  onDragOver: function(event) {
    event.preventDefault();
  },

  onDrop: function(event) {
    event.preventDefault();
    var droppedItem = JSON.parse(event.dataTransfer.getData("draggedItem"));
    this.props.onCardDrop(
      this.props.index,
      new RoboRacer.Models.InstructionCard(droppedItem)
    );
  },

  render: function() {
    var register = this.getModel();
    var instructionCard = register.get('instruction_card');
    if (instructionCard) {
      var instructionCardView = <RoboRacer.Views.InstructionCard
        model={instructionCard}
        onClick={this.props.onInstructionCardClick}
      />
    }

    return (
      <li
        className="register"
        onDragOver={ this.onDragOver }
        onDrop={ this.onDrop }>
        { instructionCardView }
      </li>);
  }
});
