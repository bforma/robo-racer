/** @jsx React.DOM */
RoboRacer.Views.Tiles = React.createBackboneClass({
  createTile: function(tile) {
    return new RoboRacer.Views.Tile({
      key: "x" + tile.get('x') + ",y" + tile.get('y'),
      model: tile
    });
  },

  render: function() {
    return (
      <div className="tiles">
        { this.getCollection().map(this.createTile) }
      </div>
    );
  }
});
