/** @jsx React.DOM */
RoboRacer.Views.Opponent = React.createClass({
  render: function() {
    return (
      <li>
        <h3>RoboBoob</h3>
        <p className="status pending" />
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
