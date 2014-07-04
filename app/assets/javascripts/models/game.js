RoboRacer.Models.Game = Backbone.Model.extend({
  idAttribute: '_id',
  urlRoot: '/api/games',

  initialize: function() {
    this.set('board', new RoboRacer.Models.Board());
    var hand = new RoboRacer.Collections.Hand();
    hand.meta('current_player_id', this.get('current_player_id'));
    this.set('hand', hand);

    RoboRacer.App.socket.on('player_joined_game_event', this.playerJoinedGame, this);
    RoboRacer.App.socket.on('player_left_game_event', this.playerLeftGame, this);
    RoboRacer.App.socket.on('game_started_event', this.gameStarted, this);
  },

  parse: function(model) {
    console.log("parse", model);

    return {
      _id: model._id,
      host_id: model.host_id,
      player_ids: model.player_ids,
      state: model.state,
      opponents: this.parseOpponents(model),
      board: this.parseBoard(model),
      hand: this.parseHand(model)
    };
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

  parseOpponents: function(model) {
    var opponents = new RoboRacer.Collections.Opponents();
    opponents.add(_.filter(model.player_ids, function(playerId) {
      return playerId !== this.get('current_player_id');
    }.bind(this)).map(function(playerId) {
      return {_id: playerId};
    }));
    return opponents;
  },

  parseHand: function(model) {
    var hand = this.get('hand');
    if(model.hands) {
      // TODO let the API return a projection of the current game from the
      // player's perspective (ie. not exposing other player's hands etc.)
      var currentPlayerHand = _.find(model.hands, function(hand) {
        return hand.player_id === this.get('current_player_id');
      }.bind(this));
      hand.add(currentPlayerHand.instruction_cards);
    }
    return hand;
  },

  currentPlayerInGame: function() {
    return _.include(this.get('player_ids'), this.get('current_player_id'));
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

  join: function() {
    this.execute('join');
  },

  leave: function() {
    this.execute('leave');
  },

  start: function() {
    this.execute('start');
  },

  execute: function(command) {
    $.ajax({
      url: this.url() + '/' + command,
      type: 'PUT'
    });
  },

  playerJoinedGame: function(event) {
    this.get('player_ids').push(event.player_id);
    if (event.player_id !== this.get('current_player_id')) {
      this.get('opponents').add({_id: event.player_id});
    }
    this.trigger('change:player_ids');
  },

  playerLeftGame: function(event) {
    _.remove(this.get('player_ids'), function(player_id) {
      return player_id == event.player_id;
    });
    if (event.player_id !== this.get('current_player_id')) {
      this.get('opponents').remove(event.player_id);
    }
    this.trigger('change:player_ids');
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
  }
});
