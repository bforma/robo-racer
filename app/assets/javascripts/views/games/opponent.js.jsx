/** @jsx React.DOM */
RoboRacer.Views.Opponent = React.createBackboneClass({
  render: function() {
    var className = "opponent " +
      RoboRacer.Collections.Opponents.color(this.getModel().get('_id'));

    return (
      <li className={ className }>
        { this.getModel().get('name') }
      </li>
    );
  }
});
