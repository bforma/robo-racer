/** @jsx React.DOM */
RoboRacer.Views.Opponent = React.createBackboneClass({
  render: function() {
    var className = "opponent " +
      RoboRacer.Collections.Opponents.color(this.getModel().get('_id'));

    return (
      <li className={ className }>
        <h3>{ this.getModel().get('name') }</h3>

        <ul className="slots">
          <li className="slot"><span className="card_empty" /></li>
          <li className="slot"><span className="card_empty" /></li>
          <li className="slot"><span className="card_empty" /></li>
          <li className="slot"><span className="card_empty" /></li>
          <li className="slot"><span className="card_empty" /></li>
        </ul>
      </li>
    );
  }
});
