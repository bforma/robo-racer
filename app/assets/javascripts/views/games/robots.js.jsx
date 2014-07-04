/** @jsx React.DOM */
RoboRacer.Views.Robots = React.createBackboneClass({
  createRobot: function(robot, n) {
    return new RoboRacer.Views.Robot({
      key: n,
      number: n,
      model: robot
    });
  },

  render: function() {
    return (
      <div className="robots">
        { this.getCollection().map(this.createRobot) }
      </div>
    );
  }
});
