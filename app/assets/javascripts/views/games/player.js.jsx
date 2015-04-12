RoboRacer.Views.Player = React.createBackboneClass({
  render: function() {
    var className = "player " +
      RoboRacer.Collections.Players.color(this.getModel().get('_id'));

    var playerStatus = React.addons.classSet({
      'player-status': true,
      'pending fa fa-clock-o': !this.getModel().hasCommittedProgram(),
      'committed fa fa-check': this.getModel().hasCommittedProgram()
    });

    return (
      <li className={ className }>
        <span className="player-name">{ this.getModel().get('name') }</span>
        <span className={playerStatus} />
      </li>
    );
  }
});
