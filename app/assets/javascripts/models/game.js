RoboRacer.Models.Game = Backbone.Model.extend({
  idAttribute: '_id',
  urlRoot: '/api/games',

  initialize: function() {
    this.set('board', new RoboRacer.Models.Board());
    this.set('players', new RoboRacer.Collections.Players());

    RoboRacer.App.socket.on('player_joined_game_event', this.playerJoinedGame, this);
    RoboRacer.App.socket.on('player_left_game_event', this.playerLeftGame, this);
    RoboRacer.App.socket.on('game_started_event', this.gameStarted, this);
    RoboRacer.App.socket.on('game_round_started_event', this.gameRoundStarted, this);
  },

  // load state

  parse: function(model) {
    console.log("parse", model);

    return _.merge(model, {
      players: this.parsePlayers(model),
      board: this.parseBoard(model),
    });
  },

  parseBoard: function(model) {
    var board = this.get('board');
    if (model.board) {
      board.set('tiles', new RoboRacer.Collections.Tiles(model.board.tiles));
      board.set('spawns', new RoboRacer.Collections.Spawns(model.board.spawns));
      board.set('checkpoints', new RoboRacer.Collections.Checkpoints(model.board.checkpoints));
      board.set('robots', new RoboRacer.Collections.Robots(model.board.robots));
    }
    return board;
  },

  parsePlayers: function(model) {
    var players = this.get('players');
    _.each(model.players, function(player) {
      players.add(this.parsePlayer(player));
    }.bind(this));
    return players;
  },

  parsePlayer: function(model) {
    var hand = new RoboRacer.Collections.Hand(model.hand.instruction_cards);
    var program = new RoboRacer.Collections.Program();
    _.each(model.program.instruction_cards, function(instructionCard, index) {
      program.program(index, new RoboRacer.Models.InstructionCard(instructionCard));
    });

    var player = {
      '_id': model.player_id,
      'hand': hand,
      'program': program
    };
    return player;
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

  // events

  playerJoinedGame: function(event) {
    this.trigger("change:players");
  },

  playerLeftGame: function(event) {
    this.trigger("change:players");
  },

  gameStarted: function(event) {
    var board = this.get('board');
    board.set('tiles', new RoboRacer.Collections.Tiles(
      _.map(event.tiles, function(tile, _) {
        return tile;
      })
    ));

    this.set('instruction_deck_size', event.instruction_deck_size);
    this.set('state', event.state);
  },

  gameRoundStarted: function(event) {
    this.set('round_number', event.game_round.number);
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
