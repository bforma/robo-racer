/** @jsx React.DOM */
RoboRacer.Views.Spawn = React.createBackboneClass({
  render: function() {
    var className = "spawn" +
      " x_" + this.getModel().get('x') +
      " y_" + this.getModel().get('y') +
      " " + RoboRacer.Collections.Players.color(this.getModel().get('player_id')) +
      " face_180";

    return (
      <div className={ className }></div>
    );
  }
});
