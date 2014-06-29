/** @jsx React.DOM */
RoboRacer.Views.Game = React.createClass({
  mixins: [ ModelMixin ],

  getBackboneModels: function() {
    return [ this.props.model ];
  },

  render: function() {
    var game = this.props.model;

    return (
      <div className="mod-game">
        <div className="viewport">
          <header>
            <div className="round"></div>
            <div className="status"></div>
            <div className="current_event"></div>
          </header>

          <div className="body">
            <div className="left">
              {RoboRacer.Views.Opponents({collection: game.get('opponents')})}
            </div>

            <div className="right">
            {/*
              <div className="table">
                {RoboRacer.Views.Board()}
              </div>
              <div className="player_area">
                instruction slots
              </div>
             */}
            </div>
          </div>
        </div>
      </div>
    );
  }
});
