/** @jsx React.DOM */
RoboRacer.Views.Board = React.createBackboneClass({
  render: function() {
    var board = this.getModel();

    return (
      <div className="mod-board perspective">
        <div className="body">
          { RoboRacer.Views.Tiles({collection: board.get('tiles')}) }
          { RoboRacer.Views.Spawns({collection: board.get('spawns')}) }
          { RoboRacer.Views.Checkpoints({collection: board.get('checkpoints')}) }
          { RoboRacer.Views.Robots({collection: board.get('robots')}) }
        </div>
      </div>
    );
  }
});
