RoboRacer.Views.Checkpoint = React.createBackboneClass({
  render: function() {
    var className = "checkpoint" +
      " x" + this.getModel().get('x') +
      " y" + this.getModel().get('y');

    return (
      <b className={ className }></b>
    );
  }
});
