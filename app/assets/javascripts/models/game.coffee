RoboRacer.Models.Game = Backbone.Model.extend(
  urlRoot: '/api/games'
  initialize: ->
    @set 'board', new (RoboRacer.Models.Board)
    @set 'players', new (RoboRacer.Collections.Players)
    return
  currentPlayer: ->
    @get('players').findWhere '_id': @get('current_player_id')
  currentPlayerInGame: ->
    _.include @get('players').pluck('_id'), @get('current_player_id')
  currentPlayerIsHost: ->
    @get('current_player_id') == @get('host_id')
  lobbying: ->
    @get('state') == 'lobbying'
  running: ->
    @get('state') == 'running'
  join: ->
    @execute 'join'
    return
  leave: (options) ->
    @execute 'leave', options
    return
  start: ->
    @execute 'start'
    return
  programRobot: ->
    instructionCards = _.map(@currentPlayer().get('program').models, (register) ->
      register.get('instruction_card').attributes
    )
    @execute 'program_robot', instruction_cards: instructionCards
    return
  execute: (command, data, options) ->
    options = options or {}
    data = data or {}
    $.ajax
      url: @url() + '/' + command
      type: 'PUT'
      data: data
      success: options.success
    return
)
