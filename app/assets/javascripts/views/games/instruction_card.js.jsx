/** @jsx React.DOM */
RoboRacer.Views.InstructionCard = React.createBackboneClass({
  render: function() {
    var card = this.getModel();
    var text = card.get('action') +
      ' ' + card.get('amount') +
      ' (' + card.get('priority') + ')';

    var draggable = this.props.onDragStart !== undefined;

    return (
      <p className="instruction_card"
         draggable={ draggable }
         onDragStart={ this.props.onDragStart }
         onClick={ this.onClick }>
        { text }
      </p>
    );
  },

  onClick: function(event) {
    this.props.onClick(event, this.getModel());
  }
});
