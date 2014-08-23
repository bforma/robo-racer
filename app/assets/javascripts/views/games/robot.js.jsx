/** @jsx React.DOM */
RoboRacer.Views.Robot = React.createBackboneClass({
  render: function() {
    var color = RoboRacer.Collections.Players.color(this.getModel().get('player_id'));
    var robotClasses = "robot" +
      " x" + this.getModel().get('x') +
      " y" + this.getModel().get('y') +
      " " + color +
      " face_" + this.getModel().get('facing');
    var topClasses = "top " + color;

    return (
      <b className={ robotClasses }>
        <b className="back"></b>
        <b className="leg">
          <b className="back"></b>
        </b>
        <b className="leg">
          <b className="back"></b>
        </b>
        <b className="bottom">
          <b className="back"></b>
        </b>
        <b className={ topClasses }>
          <b className="back"></b>
          <b className="eye" data-left>
            <b className="back"></b>
          </b>
          <b className="eye" data-right>
            <b className="back"></b>
          </b>
          <b className="antenna">
            <b className="back"></b>
          </b>
        </b>
      </b>
    );
  }
});
