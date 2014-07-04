/** @jsx React.DOM */
RoboRacer.Views.Tile = React.createBackboneClass({
  render: function() {
    var className = "tile" +
      " x_" + this.getModel().get('x') +
      " y_" + this.getModel().get('y');

    return <b className={className} />;
  }
});
