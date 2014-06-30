/** @jsx React.DOM */
RoboRacer.Views.Game = React.createBackboneClass({
  render: function() {
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
              { RoboRacer.Views.Opponents({collection: this.getModel().get('opponents')}) }
            </div>

            {/*
            <div className="right">
              <div className="table">
                {RoboRacer.Views.Board()}
              </div>
              <div className="player_area">
                instruction slots
              </div>
            </div>
            */}
          </div>
        </div>
      </div>
    );
  }
});
