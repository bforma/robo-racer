RoboRacer.Collections.Program = Backbone.Collection.extend({
  model: RoboRacer.Models.Register,

  initialize: function(models) {
    this._meta = {};

    _.range(5).forEach(function() {
      this.add(new RoboRacer.Models.Register());
    }.bind(this));
  },

  meta: function(prop, value) {
    if (value === undefined) {
      return this._meta[prop]
    } else {
      this._meta[prop] = value;
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
