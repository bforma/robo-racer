RoboRacer.Views.Players = React.createBackboneClass({
  createPlayer: function(player) {
    return <RoboRacer.Views.Player key={player.get("_id")} model={player} />
  },

  render: function() {
    return (
      <ol className="mod-players">
        { this.getCollection().map(this.createPlayer) }
      </ol>
    );
  }
});
