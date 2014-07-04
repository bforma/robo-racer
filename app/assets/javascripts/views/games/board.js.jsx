/** @jsx React.DOM */
RoboRacer.Views.Board = React.createBackboneClass({
  render: function() {
    var board = this.getModel();

    return (
      <div className="board">
        { RoboRacer.Views.Tiles({collection: board.get('tiles')}) }
        { RoboRacer.Views.Robots({collection: board.get('robots')}) }
      </div>
    );
  }
});
