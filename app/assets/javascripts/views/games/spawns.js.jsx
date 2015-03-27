RoboRacer.Views.Spawns = React.createBackboneClass({
  createSpawn: function(spawn, n) {
    return <RoboRacer.Views.Spawn
      key={n}
      number={n}
      model={spawn}
    />
  },

  render: function() {
    return (
      <div className="spawns">
        { this.getCollection().map(this.createSpawn) }
      </div>
    );
  }
});
