/** @jsx React.DOM */
RoboRacer.Views.Opponent = React.createBackboneClass({
  render: function() {
    return (
      <li>
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
