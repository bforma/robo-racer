/** @jsx React.DOM */
RoboRacer.Views.Player = React.createBackboneClass({
  render: function() {
    var className = "opponent " +
      RoboRacer.Collections.Players.color(this.getModel().get('_id'));

    return (
      <li className={ className }>
        { this.getModel().get('name') }
      </li>
    );
  }
});
