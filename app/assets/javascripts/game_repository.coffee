RoboRacer.GameRepository = Class.extend(
  games: {}

  add: (game) ->
    @games[game.id] = game

  find: (id) ->
    @games[id] || throw new Error('No game found for id "' + id + '"')
)
