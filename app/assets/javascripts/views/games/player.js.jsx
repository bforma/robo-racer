/** @jsx React.DOM */
RoboRacer.Views.Player = React.createBackboneClass({
  mixins: [
    React.BackboneMixin("player"),
    React.BackboneMixin("program", "program:committed program:reset")
  ],

  render: function() {
    var className = "opponent " +
      RoboRacer.Collections.Players.color(this.props.player.get('_id'));

    var playerStatus = React.addons.classSet({
      'status': true,
      'pending fa fa-clock-o': !this.props.program.isCommitted(),
      'committed fa fa-check': this.props.program.isCommitted()
    });

    return (
      <li className={ className }>
        { this.props.player.get('name') }
        <span className={playerStatus} />
      </li>
    );
  }
});
