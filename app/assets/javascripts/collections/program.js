RoboRacer.Collections.Program = Backbone.Collection.extend({
  model: RoboRacer.Models.Register,

  initialize: function(models) {
    this._meta = {};

    _.range(5).forEach(function() {
      this.add(new RoboRacer.Models.Register());
    }.bind(this));

    RoboRacer.App.socket.on('game_round_started_event', this.gameRoundStarted, this);
    RoboRacer.App.socket.on('robot_programmed_event', this.robotProgrammed, this);
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

    this.trigger("program:reset");
  },

  robotProgrammed: function(event) {
    if(this.meta('player').get('_id') === event.player_id) {
      _.each(this.models, function(register, index) {
        register.set('instruction_card', new RoboRacer.Models.InstructionCard(
          event.instruction_cards[index])
        );
      });

      this.trigger("program:committed");
    }
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
  },

  isCommitted: function() {
    return _.every(this.models, function(register) {
      return register.get('instruction_card');
    });
  }
});
