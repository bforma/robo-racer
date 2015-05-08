RoboRacer.Models.Player = Backbone.Model.extend(
  idAttribute: '_id'
  urlRoot: '/api/players'
  initialize: ->
    @set 'hand', new (RoboRacer.Collections.Hand)
    @set 'program', new (RoboRacer.Collections.Program)
    @set 'committedProgram', false
    @set 'revealedRegisters', new (RoboRacer.Collections.Program)
    return
  programRegister: (registerIndex, instructionCard) ->
    hand = @get('hand')
    cardInHand = hand.findWhere(priority: instructionCard.get('priority'))
    hand.remove cardInHand
    replaced = @get('program').program(registerIndex, instructionCard)
    if replaced
      hand.add replaced
    return
  unprogramRegister: (registerIndex, instructionCard) ->
    @get('program').unprogram registerIndex
    @get('hand').add instructionCard
    return
  programNextEmptyRegister: (instructionCard) ->
    program = @get('program')
    nextEmpty = program.find((register) ->
      register.isEmpty()
    )
    if nextEmpty
      index = program.indexOf(nextEmpty)
      @programRegister index, instructionCard
    return
  hasCommittedProgram: ->
    @get 'committedProgram'
)
