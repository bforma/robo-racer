RoboRacer.Models.Game = Backbone.Model.extend(
  urlRoot: "/api/games"

  initialize: ->
    @set "board", new (RoboRacer.Models.Board)
    @set "players", new (RoboRacer.Collections.Players)

  currentPlayer: ->
    @get("players").findWhere "id": @get("current_player_id")

  currentPlayerInGame: ->
    _.include @get("players").pluck("id"), @get("current_player_id")

  currentPlayerIsHost: ->
    @get("current_player_id") == @get("host_id")

  lobbying: ->
    @get("state") == "lobbying"

  running: ->
    @get("state") == "running"

  join: ->
    @execute "join"

  leave: (options) ->
    @execute "leave", options

  start: ->
    @execute "start"

  programRobot: ->
    instructionCards = _.map(@currentPlayer().get("program").models, (register) ->
      register.get("instruction_card").attributes
    )
    @execute "program_robot", instruction_cards: instructionCards

  execute: (command, data, options) ->
    options = options or {}
    data = data or {}
    $.ajax
      url: @url() + "/" + command + "?access_token=" + RoboRacer.accessToken
      type: "PUT"
      data: JSON.stringify(data)
      success: options.success
)
