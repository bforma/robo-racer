/** @jsx React.DOM */
RoboRacer.Views.Hand = React.createBackboneClass({
  createInstructionCard: function(instructionCard, n) {
    return new RoboRacer.Views.InstructionCard({
      key: n,
      model: instructionCard
    });
  },

  render: function() {
    return (
      <ol className="hand">
        { this.getCollection().map(this.createInstructionCard) }
      </ol>
    );
  }
});
