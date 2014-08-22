RoboRacer.Models.Game = Backbone.Model.extend({
  urlRoot: '/api/games',

  initialize: function() {
    this.set('board', new RoboRacer.Models.Board());
    this.set('players', new RoboRacer.Collections.Players());
  },

  // queries

  currentPlayer: function() {
    return this.get('players').findWhere({'_id': this.get('current_player_id')});
  },

  currentPlayerInGame: function() {
    return _.include(this.get('players').pluck("_id"), this.get('current_player_id'));
  },

  currentPlayerIsHost: function() {
    return this.get('current_player_id') === this.get('host_id');
  },

  lobbying: function() {
    return this.get('state') === 'lobbying';
  },

  running: function() {
    return this.get('state') === 'running';
  },

  // commands

  join: function() {
    this.execute('join');
  },

  leave: function(options) {
    this.execute('leave', options);
  },

  start: function() {
    this.execute('start');
  },

  programRobot: function() {
    var instructionCards = _.map(
      this.currentPlayer().get('program').models,
      function(register) {
        return register.get('instruction_card').attributes;
      }
    );

    this.execute('program_robot', {instruction_cards: instructionCards});
  },

  execute: function(command, data, options) {
    options = options || {};
    data = data || {};
    $.ajax({
      url: this.url() + '/' + command,
      type: 'PUT',
      data: data,
      success: options.success
    });
  },

  // other

  programRegister: function(registerIndex, instructionCard) {
    var hand = this.currentPlayer().get('hand');
    var cardInHand = hand.findWhere({
      priority: instructionCard.get('priority')
    });
    hand.remove(cardInHand);

    var replaced = this.currentPlayer().get('program').program(
      registerIndex,
      instructionCard
    );
    if (replaced) {
      hand.add(replaced);
    }
  },

  programNextEmptyRegister: function(instructionCard) {
    var program = this.currentPlayer().get('program');
    var nextEmpty = program.find(function(register) {
      return register.isEmpty();
    });

    if (nextEmpty) {
      var index = program.indexOf(nextEmpty);
      this.programRegister(index, instructionCard);
    }
  },

  unprogramRegister: function(registerIndex, instructionCard) {
    this.currentPlayer().get('program').unprogram(registerIndex);
    this.currentPlayer().get('hand').add(instructionCard);
  }
});
