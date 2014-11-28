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
  }
});
