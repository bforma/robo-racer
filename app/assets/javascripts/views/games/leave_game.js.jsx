/** @jsx React.DOM */
RoboRacer.Views.LeaveGame = React.createBackboneClass({
  render: function() {
    return <button className="button" onClick={this.props.onClick}>Leave game</button>
  }
});
