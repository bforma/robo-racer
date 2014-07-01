/** @jsx React.DOM */
RoboRacer.Views.JoinGame = React.createBackboneClass({
  render: function() {
    return <button className="button" onClick={this.props.onClick}>Join game</button>
  }
});
