class DeckEntity < BaseEntity

  def initialize(instruction_cards)
    @drawable = instruction_cards.dup
    @discarded = Array.new
    @dealt = Array.new
  end

  def deal_card(player_id)
    card = @drawable.first
    return (shuffle; deal_card(player_id)) unless card

    apply InstructionCardDealtEvent.new(id, player_id, card)
  end

  def discard_card(card)
    raise CardAlreadyDiscardedError if @discarded.include?(card)
    raise CardNotYetDealtError if @drawable.include?(card)
    raise UnknownCardError unless @dealt.include?(card)

    apply InstructionCardDiscardedEvent.new(id, card)
  end

  def shuffle
    raise OutOfCardsError if @discarded.empty?

    apply InstructionDeckShuffledEvent.new(id, @discarded.shuffle)
  end

  route_event InstructionCardDealtEvent do |event|
    @drawable.delete(event.instruction_card)
    @dealt << event.instruction_card
  end

  route_event InstructionCardDiscardedEvent do |event|
    @discarded << event.instruction_card
  end

  route_event InstructionDeckShuffledEvent do |event|
    @drawable = event.instruction_cards.dup
    @discarded = Array.new
  end

private

  def id
    aggregate_root.id
  end
end

OutOfCardsError = Class.new(StandardError)
UnknownCardError = Class.new(StandardError)
CardNotYetDealtError = Class.new(StandardError)
CardAlreadyDiscardedError = Class.new(StandardError)
