/** @jsx React.DOM */
RoboRacer.Views.Board = React.createClass({
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
    var rows = _.range(12).map(function(row) {
      return new RoboRacer.Views.BoardRow({key: row, y: row});
    });

    var robots = this.COLORS.map(function(color, index) {
      return new RoboRacer.Views.Robot(
        {key: color, x: index, y: 0, color: color}
      );
    });

    return (
      <div className="board">
        { rows }
        { robots }
      </div>
    );
  }
});
