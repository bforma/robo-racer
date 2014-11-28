/** @jsx React.DOM */
RoboRacer.Views.Hand = React.createBackboneClass({
  mixins: [
    React.BackboneMixin('player'),
    React.BackboneMixin({
      modelOrCollection: function(props) {
        return props.player.get('hand');
      }
    })
  ],

  createInstructionCard: function(instructionCard, n) {
    if(! this.props.player.hasCommittedProgram()) {
      var onDragStart = function(event) {
        event.dataTransfer.setData(
          'draggedItem',
          JSON.stringify(instructionCard)
        );
      };
      var onClick = this.onInstructionCardClick;
    }

    return <li key={n}>
      <RoboRacer.Views.InstructionCard
        model={instructionCard}
        onDragStart={onDragStart}
        onClick={onClick}
      />
    </li>
  },

  render: function() {
    var classes = React.addons.classSet({
      'mod-hand': true,
      'disabled': this.props.player.hasCommittedProgram()
    });
    return (
      <ul className={classes}>
        { this.props.player.get('hand').map(this.createInstructionCard) }
      </ul>
    );
  },

  onInstructionCardClick: function(event, instructionCard) {
    this.props.player.programNextEmptyRegister(instructionCard);
  }
});
