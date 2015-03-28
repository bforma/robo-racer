RoboRacer.Views.SidePanel = React.createClass({
  render: function() {
    return (
      <div className={'panel ' + this.props.orientation}>
        <div className="content">
          {this.props.children}
        </div>
      </div>
    );
  }
});
