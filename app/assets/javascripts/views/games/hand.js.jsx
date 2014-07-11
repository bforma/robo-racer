/** @jsx React.DOM */
RoboRacer.Views.Hand = React.createBackboneClass({
  createInstructionCard: function(instructionCard, n) {
    return <li>
      {
        new RoboRacer.Views.InstructionCard({
          key: n,
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
