/** @jsx React.DOM */
RoboRacer.Views.Checkpoints = React.createBackboneClass({
  createCheckpoint: function(checkpoint, n) {
    return new RoboRacer.Views.Checkpoint({
      key: n,
      model: checkpoint
    });
  },

  render: function() {
    return (
      <div className="checkpoints">
        { this.getCollection().map(this.createCheckpoint) }
      </div>
    );
  }
});
