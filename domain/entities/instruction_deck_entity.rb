class InstructionDeckEntity < BaseEntity
  inheritable_accessor :event_router do
    Fountain::Router.create_router
  end

  def initialize(instruction_cards)
    @drawable = instruction_cards.dup
    @discarded = Array.new
    @dealt = Array.new
  end

  def deal_card(player_id)
    card = @drawable.first
    if card
      apply InstructionCardDealt.new(id, player_id, card)
    else
      shuffle
      deal_card(player_id)
    end
  end

  def discard_card(card)
    raise CardAlreadyDiscardedError if @discarded.include?(card)
    raise CardNotYetDealtError if @drawable.include?(card)
    raise UnknownCardError unless @dealt.include?(card)

    apply InstructionCardDiscarded.new(id, card)
  end

  def shuffle
    raise OutOfCardsError if @discarded.empty?

    apply InstructionDeckShuffled.new(id, @discarded.shuffle)
  end

  route_event InstructionCardDealt do |event|
    @drawable.delete(event.instruction_card)
    @dealt << event.instruction_card
  end

  route_event InstructionCardDiscarded do |event|
    @discarded << event.instruction_card
  end

  route_event InstructionDeckShuffled do |event|
    @drawable = event.instruction_cards.dup
    @discarded = Array.new
  end
end

OutOfCardsError = Class.new(DomainError)
UnknownCardError = Class.new(DomainError)
CardNotYetDealtError = Class.new(DomainError)
CardAlreadyDiscardedError = Class.new(DomainError)
