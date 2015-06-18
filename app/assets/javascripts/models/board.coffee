RoboRacer.Models.Board = Backbone.Model.extend(
  initialize: ->
    @set "tiles", new (RoboRacer.Collections.Tiles)
    @set "spawns", new (RoboRacer.Collections.Spawns)
    @set "checkpoints", new (RoboRacer.Collections.Checkpoints)
    @set "robots", new (RoboRacer.Collections.Robots)
)
