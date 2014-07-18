/** @jsx React.DOM */
RoboRacer.Views.Players = React.createBackboneClass({
  createPlayer: function(player) {
    return new RoboRacer.Views.Player({
      key: player.get("_id"),
      player: player,
      program: player.get('program')
    });
  },

  render: function() {
    return (
      <ol className="mod-opponents">
        { this.getCollection().map(this.createPlayer) }
      </ol>
    );
  }
});
