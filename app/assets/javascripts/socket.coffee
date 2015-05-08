RoboRacer.Socket = Class.extend(initialize: (gameEventListener, accessToken, gameId) ->
  url = window.location.protocol + '//' + window.location.hostname + ':8080'
  connection = io(url)

  connection.on 'connect', ->
    connection.emit 'authenticate', accessToken

  connection.on 'disconnect', (->
    console.log 'disconnected', arguments
  ).bind(this)

  connection.on 'authenticated', ->
    connection.emit 'join', gameId

  connection.on 'event', (event) ->
    try
      gameEventListener.handleEvent JSON.parse(event)
    catch error
      console.error error
      throw error
)
