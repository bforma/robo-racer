RoboRacer.Collections.Program = Backbone.Collection.extend(
  model: RoboRacer.Models.Register
  initialize: ->
    @reset()
    return
  program: (index, card) ->
    # remove and add in order to trigger proper change event
    replacedRegister = @at(index)
    @remove replacedRegister
    @add new (RoboRacer.Models.Register)(instruction_card: card), at: index
    replacedRegister.get 'instruction_card'
  unprogram: (index) ->
    @program index, undefined
    return
  allRegistersFilled: ->
    _.every @models, (register) ->
      register.get 'instruction_card'
  reset: ->
    Backbone.Collection::reset.call this
    _.range(5).forEach (->
      @add new (RoboRacer.Models.Register)
      return
    ).bind(this)
    return
)
