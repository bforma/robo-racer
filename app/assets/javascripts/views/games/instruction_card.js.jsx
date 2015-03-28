RoboRacer.Views.InstructionCard = React.createBackboneClass({
  render: function() {
    var card = this.getModel();
    var draggable = this.props.onDragStart !== undefined;

    if(this.props.onClick) {
      var onClick = function(event) {
        this.props.onClick(event, this.getModel());
      }.bind(this);
    }

    return (
      <div className="comp-instruction_card"
         draggable={ draggable }
         onDragStart={ this.props.onDragStart }
         onClick={ onClick }>
        <div className={ this.translateToIcon() }></div>
        <div className="text">{ this.translateToText() }</div>
        <div className="priority">{ card.get('priority') }</div>
      </div>
    );
  },

  translateToIcon: function() {
    return 'icon fa ' + RoboRacer.Views.InstructionCard.CARD_TRANSLATIONS[
      this.getTranslationKey()
    ].icon;
  },

  translateToText: function() {
    return RoboRacer.Views.InstructionCard.CARD_TRANSLATIONS[
      this.getTranslationKey()
    ].text;
  },

  getTranslationKey: function() {
    return this.getModel().get('action') + this.getModel().get('amount');
  }
});

RoboRacer.Views.InstructionCard.CARD_TRANSLATIONS = {
  'R180': {icon: 'fa-magnet', text: 'U-turn'},
  'R-90': {icon: 'fa-mail-reply', text: 'Left'},
  'R90': {icon: 'fa-mail-forward', text: 'Right'},
  'M1': {icon: 'fa-arrow-up', text: 'Move 1'},
  'M2': {icon: 'fa-arrow-up', text: 'Move 2'},
  'M3': {icon: 'fa-arrow-up', text: ' Move 3'},
  'M-1': {icon: 'fa-arrow-down', text: 'Back-up'}
};
