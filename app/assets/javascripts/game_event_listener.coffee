RoboRacer.GameEventListener = Class.extend(
  initialize: (gameRepository) ->
    @gameRepository = gameRepository

  handleEvents: (events) ->
    startedAt = new Date
    _(events).forEach ((event) ->
      @handleEvent event
    ).bind(this)
    endedAt = new Date
    duration = endedAt - startedAt
    console.log "Replayed %d events in %d ms", events.length, duration

  handleEvent: (event) ->
    eventMethodName = @methodName(event.payload_type)
    eventMethod = @[eventMethodName]
    if typeof eventMethod == "function"
      console.log "Handle '" + event.payload_type + "'"
      eventMethod.call this, event.payload
    else
      console.warn "Cannot handle event with payload_type '" + event.payload_type + "'"

  methodName: (payload_type) ->
    "on" + payload_type

  onGameCreatedEvent: (payload) ->
    @gameRepository.add new (RoboRacer.Models.Game)(payload)

  onPlayerJoinedGameEvent: (payload) ->
    game = @gameRepository.find(payload.id)
    game.get("players").add id: payload.player_id

  onPlayerLeftGameEvent: (payload) ->
    game = @gameRepository.find(payload.id)
    players = game.get("players")
    player = players.findWhere(id: payload.player_id)
    players.remove player

  onGameStartedEvent: (payload) ->
    game = @gameRepository.find(payload.id)
    game.set "state", payload.state
    game.get("board").set "tiles", new (RoboRacer.Collections.Tiles)(_.map(payload.tiles, (tile, _) ->
      tile
    ))

  onSpawnPlacedEvent: (payload) ->
    game = @gameRepository.find(payload.id)
    game.get("board").get("spawns").add new (RoboRacer.Models.Spawn)(
      player_id: payload.player_id
      x: payload.spawn.x
      y: payload.spawn.y
      facing: payload.spawn.facing)

  onGoalPlacedEvent: (payload) ->
    game = @gameRepository.find(payload.id)
    game.get("board").get("checkpoints").add new (RoboRacer.Models.Checkpoint)(payload.goal)

  onRobotSpawnedEvent: (payload) ->
    game = @gameRepository.find(payload.id)
    game.get("board").get("robots").add new (RoboRacer.Models.Robot)(
      player_id: payload.player_id
      x: payload.robot.x
      y: payload.robot.y
      facing: payload.robot.facing)

  onGameRoundStartedEvent: (payload) ->
    game = @gameRepository.find(payload.id)
    game.set "round_number", payload.game_round.number
    _(payload.hands).forEach (instructionCards, playerId) ->
      player = game.get("players").findWhere(id: playerId)
      player.get("hand").set instructionCards

    _(payload.programs).forEach (instructionCards, playerId) ->
      player = game.get("players").findWhere(id: playerId)
      player.set "committedProgram", false
      player.get("program").forEach (register, index) ->
        register.set "instruction_card", instructionCards[index]

      player.get("revealedRegisters").reset()


  onInstructionCardDealtEvent: (payload) ->
    game = @gameRepository.find(payload.id)
    player = game.get("players").findWhere(id: payload.player_id)
    player.get("hand").add new (RoboRacer.Models.InstructionCard)(payload.instruction_card)

  onRobotProgrammedEvent: (payload) ->
    game = @gameRepository.find(payload.id)
    player = game.get("players").findWhere(id: payload.player_id)
    player.set "committedProgram", true
    player.get("program").forEach (register, index) ->
      register.set "instruction_card", new (RoboRacer.Models.InstructionCard)(payload.instruction_cards[index])

    _(payload.instruction_cards).forEach (instructionCard) ->
      cardInHand = player.get("hand").findWhere(priority: instructionCard.priority)
      player.get("hand").remove cardInHand if cardInHand


  onInstructionCardRevealedEvent: (payload) ->
    game = @gameRepository.find(payload.id)
    player = game.get("players").findWhere(id: payload.player_id)
    register = player.get("revealedRegisters").findWhere(instruction_card: undefined)
    register.set "instruction_card", new (RoboRacer.Models.InstructionCard)(payload.instruction_card)

  onRobotRotatedEvent: (payload) ->
    game = @gameRepository.find(payload.id)
    robots = game.get("board").get("robots")
    robot = robots.findWhere(player_id: payload.player_id)
    robot.set "facing", payload.robot.facing

  onRobotMovedEvent: (payload) ->
    @moveRobot payload

  onRobotPushedEvent: (payload) ->
    @moveRobot payload

  onRobotDiedEvent: (payload) ->
    game = @gameRepository.find(payload.id)
    robots = game.get("board").get("robots")
    robot = robots.findWhere(player_id: payload.player_id)
    robots.remove robot

  moveRobot: (payload) ->
    game = @gameRepository.find(payload.id)
    robots = game.get("board").get("robots")
    robot = robots.findWhere(player_id: payload.player_id)
    robot.set
      x: payload.robot.x
      y: payload.robot.y

)
