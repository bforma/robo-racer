/** @jsx React.DOM */
RoboRacer.Views.Checkpoint = React.createBackboneClass({
  render: function() {
    var className = "checkpoint" +
      " x_" + this.getModel().get('x') +
      " y_" + this.getModel().get('y');

    return (
      <div className={ className }>{ this.getModel().get('priority') }</div>
    );
  }
});
