RoboRacer.Collections.Players = Backbone.Collection.extend({
  model: RoboRacer.Models.Player

  initialize: ->
    @on "add", @playerAdded, this

  playerAdded: (player) ->
    player.fetch()
    @constructor.color player.id, @indexOf(player)

},
  COLORS: [
    "red"
    "yellow"
    "orange"
    "pink"
    "green"
    "brown"
    "grey"
    "lightblue"
  ]
  playerIdToColor: {}
  color: (playerId, index) ->
    if index != undefined
      @playerIdToColor[playerId] = @COLORS[index]
    else
      return @playerIdToColor[playerId]
    return
)
