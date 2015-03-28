RoboRacer.Views.Tile = React.createBackboneClass({
  render: function() {
    var className =
      " x" + this.getModel().get('x') +
      " y" + this.getModel().get('y');

    return <div className={className}><b className="floor"></b></div>;
  }
});
