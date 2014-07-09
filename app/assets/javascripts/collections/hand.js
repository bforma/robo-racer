RoboRacer.Collections.Hand = Backbone.Collection.extend({
  model: RoboRacer.Models.InstructionCard,

  initialize: function() {
    this._meta = {};

    RoboRacer.App.socket.on('game_round_started_event', this.clearHand, this);
    RoboRacer.App.socket.on('instruction_card_dealt_event', this.instructionCardDealt, this);
  },

  meta: function(prop, value) {
    if (value === undefined) {
      return this._meta[prop]
    } else {
      this._meta[prop] = value;
    }
  },

  clearHand: function() {
    this.reset();
  },

  instructionCardDealt: function(event) {
    if(this.meta('current_player_id') === event.player_id) {
      this.add(new RoboRacer.Models.InstructionCard(event.instruction_card));
    }
  }
});
