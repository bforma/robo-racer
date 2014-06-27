/** @jsx React.DOM */
RoboRacer.Views.BoardRow = React.createClass({
  render: function() {
    var y = this.props.y;
    var cells = _.range(12).map(function(cell) {
      return new RoboRacer.Views.BoardTile({key: cell+","+y, x: cell, y: y});
    });

    return (
      <div className="row">
        { cells }
      </div>
    );
  }
});
