/** @jsx React.DOM */
RoboRacer.Views.Robot = React.createClass({
  render: function() {
    var x = this.props.x;
    var y = this.props.y;
    var color = this.props.color;

    return (
      <div className={ "robot x_" + x + " y_" + y + " " + color + " face_180" }></div>
    );
  }
});
