RoboRacer.Views.Player = React.createBackboneClass({
  render: function() {
    var className = "opponent " +
      RoboRacer.Collections.Players.color(this.getModel().get('_id'));

    var playerStatus = React.addons.classSet({
      'status': true,
      'pending fa fa-clock-o': !this.getModel().hasCommittedProgram(),
      'committed fa fa-check': this.getModel().hasCommittedProgram()
    });

    return (
      <li className={ className }>
        { this.getModel().get('name') }
        <span className={playerStatus} />
      </li>
    );
  }
});
