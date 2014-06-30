/** @jsx React.DOM */
RoboRacer.Views.Opponents = React.createBackboneClass({
  createOpponent: function(opponent) {
    return new RoboRacer.Views.Opponent({
      key: opponent.get("_id"),
      model: opponent
    });
  },

  render: function() {
    return (
      <ol className="opponents">
        { this.getCollection().map(this.createOpponent) }
      </ol>
    );
  }
});
