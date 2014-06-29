/** @jsx React.DOM */
RoboRacer.Views.Opponents = React.createClass({
  mixins: [ ModelMixin ],

  getBackboneModels: function() {
    return [ this.props.collection ];
  },

  render: function() {
    var opponents = this.props.collection.map(function(opponent) {
      return new RoboRacer.Views.Opponent(
        {key: opponent, model: opponent}
      );
    });

    return (
      <ol className="opponents">
        { opponents }
      </ol>
    );
  }
});
