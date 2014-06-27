/** @jsx React.DOM */
RoboRacer.Views.Opponents = React.createClass({
  render: function() {
    var opponents = _.range(7).map(function(n) {
      return new RoboRacer.Views.Opponent({key: n});
    });

    return (
      <ol className="opponents">
      { opponents }
      </ol>
    );
  }
});
