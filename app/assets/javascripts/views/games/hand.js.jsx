/** @jsx React.DOM */
RoboRacer.Views.Hand = React.createBackboneClass({
  createInstructionCard: function(instructionCard, n) {
    return <li key={n}>
      {
        new RoboRacer.Views.InstructionCard({
          model: instructionCard,
          onDragStart: function(event) {
            event.dataTransfer.setData(
              'draggedItem',
              JSON.stringify(instructionCard)
            );
          },
          onClick: this.props.onInstructionCardInHandClick
        })
      }
    </li>
  },

  render: function() {
    return (
      <ul className="mod-hand">
        { this.getCollection().map(this.createInstructionCard) }
      </ul>
    );
  }
});
