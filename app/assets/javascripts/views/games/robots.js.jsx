/** @jsx React.DOM */
RoboRacer.Views.Robots = React.createBackboneClass({
  createRobot: function(robot, n) {
    return new RoboRacer.Views.Robot({
      key: robot.get('_id').$oid,
      number: n,
      model: robot
    });
  },

  render: function() {
    return (
      <div>
        { this.getCollection().map(this.createRobot) }
      </div>
    );
  }
});
