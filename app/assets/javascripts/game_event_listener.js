RoboRacer.GameEventListener = Class.extend({
  initialize: function(gameRepository) {
    this.gameRepository = gameRepository;
  },

  handleEvents: function(events) {
    var startedAt = new Date();
    _(events).forEach(function(event) {
      this.handleEvent(event);
    }.bind(this));
    var endedAt = new Date();

    var duration = endedAt - startedAt;
    console.log('Replayed ' + events.length + ' events in ' + duration + ' ms');
  },

  handleEvent: function(event) {
    var eventMethodName = this.methodName(event.payload_type);
    var eventMethod = this[eventMethodName];
    if(typeof eventMethod === 'function') {
      console.log('Handle "' + event.payload_type + '"');
      eventMethod.call(this, event.payload);
    } else {
      console.warn('Cannot handle event with payload_type "' + event.payload_type + '"');
    }
  },

  methodName: function(payload_type) {
    return 'on' + payload_type;
  },

  // event handling methods

  onGameCreatedEvent: function(payload) {
    this.gameRepository.add(new RoboRacer.Models.Game(payload));
  },

  onPlayerJoinedGameEvent: function(payload) {
    var game = this.gameRepository.find(payload.id);
    game.get('players').add({_id: payload.player_id});
  },

  onPlayerLeftGameEvent: function(payload) {
    var game = this.gameRepository.find(payload.id);
    var players = game.get('players');
    var player = players.findWhere({_id: payload.player_id});
    players.remove(player);
  },

  onGameStartedEvent: function(payload) {
    var game = this.gameRepository.find(payload.id);
    game.set('state', payload.state);
    game.get('board').set('tiles', new RoboRacer.Collections.Tiles(
      _.map(payload.tiles, function(tile, _) {
        return tile;
      })
    ));
  },

  onSpawnPlacedEvent: function(payload) {
    var game = this.gameRepository.find(payload.id);
    game.get('board').get('spawns').add(new RoboRacer.Models.Spawn({
      player_id: payload.player_id,
      x: payload.spawn.x,
      y: payload.spawn.y,
      facing: payload.spawn.facing
    }));
  },

  onGoalPlacedEvent: function(payload) {
    var game = this.gameRepository.find(payload.id);
    game.get('board').get('checkpoints').add(
      new RoboRacer.Models.Checkpoint(payload.goal)
    );
  },

  onRobotSpawnedEvent: function(payload) {
    var game = this.gameRepository.find(payload.id);
    game.get('board').get('robots').add(new RoboRacer.Models.Robot({
      player_id: payload.player_id,
      x: payload.robot.x,
      y: payload.robot.y,
      facing: payload.robot.facing
    }));
  },

  onGameRoundStartedEvent: function(payload) {
    var game = this.gameRepository.find(payload.id);
    game.set('round_number', payload.game_round.number);

    _(payload.hands).forEach(function(instructionCards, playerId) {
      var player = game.get('players').findWhere({_id: playerId});
      player.get('hand').set(instructionCards);
    });

    _(payload.programs).forEach(function(instructionCards, playerId) {
      var player = game.get('players').findWhere({_id: playerId});
      player.set('committedProgram', false);
      player.get('program').forEach(function(register, index) {
        register.set('instruction_card', instructionCards[index]);
      });
    });
  },

  onInstructionCardDealtEvent: function(payload) {
    var game = this.gameRepository.find(payload.id);
    var player = game.get('players').findWhere({_id: payload.player_id});
    player.get('hand').add(
      new RoboRacer.Models.InstructionCard(payload.instruction_card)
    );
  },

  onRobotProgrammedEvent: function(payload) {
    var game = this.gameRepository.find(payload.id);
    var player = game.get('players').findWhere({_id: payload.player_id});

    player.set('committedProgram', true);
    player.get('program').forEach(function(register, index) {
      register.set('instruction_card', new RoboRacer.Models.InstructionCard(
        payload.instruction_cards[index]
      ));
    });

    _(payload.instruction_cards).forEach(function(instructionCard) {
      var cardInHand = player.get('hand').findWhere({
        priority: instructionCard.priority
      });
      if(cardInHand) {
        player.get('hand').remove(cardInHand);
      }
    });
  },

  onRobotRotatedEvent: function(payload) {
    var game = this.gameRepository.find(payload.id);
    var robots = game.get('board').get('robots');
    var robot = robots.findWhere({player_id: payload.player_id});
    robot.set('facing', payload.robot.facing);
  },

  onRobotMovedEvent: function(payload) {
    this.moveRobot(payload);
  },

  onRobotPushedEvent: function(payload) {
    this.moveRobot(payload);
  },

  onRobotDiedEvent: function(payload) {
    var game = this.gameRepository.find(payload.id);
    var robots = game.get('board').get('robots');
    var robot = robots.findWhere({player_id: payload.player_id});
    robots.remove(robot);
  },

  moveRobot: function(payload) {
    var game = this.gameRepository.find(payload.id);
    var robots = game.get('board').get('robots');
    var robot = robots.findWhere({player_id: payload.player_id});
    robot.set({
      x: payload.robot.x,
      y: payload.robot.y
    });
  }
});
