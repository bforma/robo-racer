RoboRacer.Collections.Hand = Backbone.Collection.extend({
  model: RoboRacer.Models.InstructionCard,

  initialize: function() {
    this._meta = {};
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
});
