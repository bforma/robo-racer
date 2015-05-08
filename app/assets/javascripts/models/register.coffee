RoboRacer.Models.Register = Backbone.Model.extend(
  isEmpty: ->
    @get('instruction_card') == undefined
)
