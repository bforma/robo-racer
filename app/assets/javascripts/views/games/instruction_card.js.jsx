/** @jsx React.DOM */
RoboRacer.Views.InstructionCard = React.createBackboneClass({
  render: function() {
    var card = this.getModel();

    return (
      <li className="instruction_card">
        { card.get('action') } { card.get('amount') } ({ card.get('priority') })
      </li>
    );
  }
});
