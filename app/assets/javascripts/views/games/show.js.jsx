/** @jsx React.DOM */
RoboRacer.Views.Game = React.createClass({
  render: function() {
    return (
      <div className="mod-game">
        <h1>It's a game!</h1>

        <div className="viewport">
          <header>
            <div className="round">Round 3</div>
            <div className="status">Playing slot 2 cards</div>
            <div className="current_event">RoboBoob: move 2</div>
          </header>

          <div className="body">
            <div className="left">
              {RoboRacer.Views.Opponents()}
            </div>

            <div className="right">
              <div className="table">
                {RoboRacer.Views.Board()}
              </div>
              <div className="player_area">
                instruction slots
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
});
