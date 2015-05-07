RoboRacer.Models.Player = Backbone.Model.extend({
  idAttribute: "_id",
  urlRoot: "/api/players",

  initialize: function() {
    this.set('hand', new RoboRacer.Collections.Hand());
    this.set('program', new RoboRacer.Collections.Program());
    this.set('committedProgram', false);
    this.set('revealedRegisters', new RoboRacer.Collections.Program());
  },

  programRegister: function(registerIndex, instructionCard) {
    var hand = this.get('hand');
    var cardInHand = hand.findWhere({
      priority: instructionCard.get('priority')
    });
    hand.remove(cardInHand);

    var replaced = this.get('program').program(
      registerIndex,
      instructionCard
    );
    if (replaced) {
      hand.add(replaced);
    }
  },

  unprogramRegister: function(registerIndex, instructionCard) {
    this.get('program').unprogram(registerIndex);
    this.get('hand').add(instructionCard);
  },

  programNextEmptyRegister: function(instructionCard) {
    var program = this.get('program');
    var nextEmpty = program.find(function(register) {
      return register.isEmpty();
    });

    if (nextEmpty) {
      var index = program.indexOf(nextEmpty);
      this.programRegister(index, instructionCard);
    }
  },

  hasCommittedProgram: function() {
    return this.get('committedProgram');
  }
});
