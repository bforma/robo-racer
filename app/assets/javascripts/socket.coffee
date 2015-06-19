RoboRacer.Socket = Class.extend(
  initialize: (gameEventListener, accessToken, gameId) ->
    url = window.location.protocol + "//" + window.location.hostname + ":8080"
    connection = io(url)

    connection.on "connect", ->
      connection.emit "authenticate", accessToken

    connection.on "disconnect", (->
      console.log "disconnected", arguments
    ).bind(this)

    connection.on "authenticated", ->
      connection.emit "join", gameId

    eventDelays = {
      "GameRoundStartedPlaying": 1500
      "InstructionCardRevealed": 250
      "RobotRotated": 1500
      "RobotMoved": 1500
      "RobotPushed": 1500
      "RobotDied": 1500
      "GameRoundFinishedPlaying": 1500
    }

    delayForEvent = (event) ->
      eventDelays[event.payload_type] || 0

    source = Rx.Observable
      .fromEvent(connection, "event")
      .map (event) -> JSON.parse(event)
      .map (event) -> event: event, delay: delayForEvent(event)
      .concatMap (x) -> Rx.Observable.empty().delay(x.delay).merge(Rx.Observable.return(x.event))

    source.subscribe (event) -> gameEventListener.handleEvent(event)
)
