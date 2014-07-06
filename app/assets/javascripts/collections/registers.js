RoboRacer.Collections.Registers = Backbone.Collection.extend({
  model: RoboRacer.Models.Register,

  initialize: function() {
    _.range(5).forEach(function() {
      this.add(new RoboRacer.Models.Register());
    }.bind(this));
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
