RoboRacer.Views.Tiles = React.createBackboneClass({
  createTile: function(tile) {
    return <RoboRacer.Views.Tile
      key={"x" + tile.get('x') + ",y" + tile.get('y')}
      model={tile}
    />
  },

  render: function() {
    return (
      <div className="tiles">
        { this.getCollection().map(this.createTile) }
      </div>
    );
  }
});
