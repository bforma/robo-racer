/** @jsx React.DOM */
RoboRacer.Views.Robot = React.createBackboneClass({
  render: function() {
    var className = "robot" +
      " x_" + this.getModel().get('x') +
      " y_" + this.getModel().get('y') +
      " " + RoboRacer.Collections.Opponents.color(this.getModel().get('player_id')) +
      " face_" + this.getModel().get('facing');

    return (
      <div className={ className }></div>
    );
  }
});
