/** @jsx React.DOM */
RoboRacer.Views.BoardTile = React.createClass({
  render: function() {
    var className = "tile x_" + this.props.x + " y_" + this.props.y;
    return <b className={className} />;
  }
});
