RoboRacer.GameRepository = Class.extend(
  games: {}
  add: (game) ->
    @games[game.id] = game
    return
  find: (id) ->
    game = @games[id]
    if game == undefined
      throw new Error('No game found for id "' + id + '"')
    game
)
