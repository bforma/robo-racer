RoboRacer.Socket = Class.extend(initialize: (gameEventListener, accessToken, gameId) ->
  url = window.location.protocol + '//' + window.location.hostname + ':8080'
  connection = io(url)
  connection.on 'connect', ->
    connection.emit 'authenticate', accessToken
    return
  connection.on 'disconnect', (->
    console.log 'disconnected', arguments
    return
  ).bind(this)
  connection.on 'authenticated', ->
    connection.emit 'join', gameId
    return
  connection.on 'event', (event) ->
    try
      gameEventListener.handleEvent JSON.parse(event)
    catch error
      console.error error
      throw error
    return
  return
)
