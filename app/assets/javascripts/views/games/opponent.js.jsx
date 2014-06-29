/** @jsx React.DOM */
RoboRacer.Views.Opponent = React.createClass({
  mixins: [ ModelMixin ],

  getBackboneModels: function() {
    return [ this.props.model ];
  },

  render: function() {
    var player = this.props.model;

    return (
      <li>
        <h3>{ player.get('name') }</h3>

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
