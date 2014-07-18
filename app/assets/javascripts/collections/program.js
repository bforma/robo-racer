RoboRacer.Collections.Program = Backbone.Collection.extend({
  model: RoboRacer.Models.Register,

  initialize: function(models) {
    this._meta = {};

    _.range(5).forEach(function() {
      this.add(new RoboRacer.Models.Register());
    }.bind(this));

    RoboRacer.App.socket.on('game_round_started_event', this.gameRoundStarted, this);
  },

  meta: function(prop, value) {
    if (value === undefined) {
      return this._meta[prop]
    } else {
      this._meta[prop] = value;
    }
  },

  gameRoundStarted: function(event) {
    var instructionCardsInProgram = event.programs[this.meta('player').get('_id')];
    _.each(this.models, function(register, index) {
      register.set('instruction_card', instructionCardsInProgram[index]);
    });
  },

  program: function(index, card) {
    // remove and add in order to trigger proper change event
    var replacedRegister = this.at(index);
    this.remove(replacedRegister);
    this.add(
      new RoboRacer.Models.Register({instruction_card: card}),
      {at: index}
    );

    return replacedRegister.get('instruction_card');
  },

  unprogram: function(index) {
    this.program(index, undefined);
  }
});
