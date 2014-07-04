/** @jsx React.DOM */
RoboRacer.Views.Robot = React.createBackboneClass({
  COLORS: [
    "red",
    "yellow",
    "orange",
    "pink",
    "green",
    "brown",
    "grey",
    "lightblue"
  ],

  render: function() {
    var className = "robot" +
      " x_" + this.getModel().get('x') +
      " y_" + this.getModel().get('y') +
      " " + this.COLORS[this.props.number] +
      " face_180";

    return (
      <div className={ className }></div>
    );
  }
});
