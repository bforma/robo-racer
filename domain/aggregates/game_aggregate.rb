class GameAggregate < BaseAggregate
  MAX_HAND_SIZE = 9

  def initialize(id, host_id)
    apply GameCreatedEvent.new(id, GameState::LOBBYING, host_id)
    apply PlayerJoinedGameEvent.new(id, host_id)
  end

  def join(player_id)
    raise GameAlreadyStartedError if @state == GameState::RUNNING
    raise AlreadyInGameError if @player_ids.include?(player_id)

    apply PlayerJoinedGameEvent.new(id, player_id)
  end

  def leave(player_id)
    raise GameAlreadyStartedError if @state == GameState::RUNNING
    raise NotInGameError unless @player_ids.include?(player_id)

    apply PlayerLeftGameEvent.new(id, player_id)
  end

  def start(player_id)
    raise NotGameOwnerError if @host_id != player_id
    raise GameAlreadyStartedError if @state == GameState::RUNNING

    deck = InstructionDeck.build
    apply GameStartedEvent.new(id, GameState::RUNNING, deck.to_value_object)

    start_round
  end

  def move_robot(speed)
    apply RobotMovedEvent.new(id, @robot.move(speed))
  end

private

  def start_round
    apply GameRoundStartedEvent.new(
      id, GameRound.new(1, Time.current, 1.minute.from_now)
    )

    deck = Deck.from_value_object(@instruction_deck)
    dealer = Dealer.new(deck, @player_ids)
    dealer.deal(MAX_HAND_SIZE) do |player_id, instruction_card|
      apply InstructionCardDealtEvent.new(id, player_id, instruction_card)
    end
  end

  route_event GameCreatedEvent do |event|
    @id = event.id
    @state = event.state
    @host_id = event.host_id
    @player_ids = Array.new

    @robot = GameUnit.new(0, 0, GameUnit::RIGHT)
  end
  
  route_event PlayerJoinedGameEvent do |event|
    @player_ids << event.player_id
  end

  route_event PlayerLeftGameEvent do |event|
    @player_ids.delete(event.player_id)
  end

  route_event GameStartedEvent do |event|
    @state = event.state
    @instruction_deck = event.instruction_deck
  end

  route_event GameRoundStartedEvent do |event|

  end
end

class Deck
  attr_reader :drawable, :drawn, :discarded

  def initialize(drawable, drawn = [], discarded = [])
    @drawable = drawable.dup
    @drawn = drawn.dup
    @discarded = discarded.dup
  end

  def self.from_value_object(deck_state)
    new(deck_state.drawable, deck_state.drawn, deck_state.discarded)
  end

  def shuffle!
    @drawable = @drawable.concat(@discarded)
    raise OutOfCardsError if drawable.empty?
    @discarded = []
    @drawn = []
    @drawable.shuffle!
  end

  def draw_card
    card = @drawable.shift
    return (shuffle!; draw_card) unless card
    @drawn << card
    card
  end

  def discard_card(card)
    raise CardAlreadyDiscardedError if @discarded.include?(card)
    raise CardNotYetDrawnError if @drawable.include?(card)
    raise UnknownCardError unless @drawn.include?(card)

    @discarded << card
  end

  def to_value_object
    DeckState.new(drawable.dup, drawn.dup, discarded.dup)
  end
end

class OutOfCardsError < StandardError; end
class UnknownCardError < StandardError; end
class CardNotYetDrawnError < StandardError; end
class CardAlreadyDiscardedError < StandardError; end

class InstructionDeck < Deck
  def self.build
    new(compose_deck)
  end

private

  DECK_COMPOSITION = [
    {type: :u_turn, count: 6, start: 10, step: 10},
    {type: :rotate_left, count: 18, start: 70, step: 20},
    {type: :rotate_right, count: 18, start: 80, step: 20},
    {type: :back_up, count: 6, start: 430, step: 10},
    {type: :move_1, count: 18, start: 490, step: 10},
    {type: :move_2, count: 12, start: 670, step: 10},
    {type: :move_3, count: 6, start: 790, step: 10},
  ]

  def self.compose_deck
    DECK_COMPOSITION.reduce([]) do |deck, card|
      card[:count].times do |n| # n starts at 0
        priority = card[:start] + n * card[:step]
        deck << InstructionCard.send(card[:type], priority)
      end

      deck
    end
  end
end

class Dealer
  def initialize(deck, players)
    @deck = deck
    @players = players
  end

  def deal(count)
    hands = {}
    count.times do
      @players.reduce(hands) do |memo, player|
        memo[player] = [] unless memo[player]
        card = @deck.draw_card
        yield(player, card) if block_given?
        memo[player] << card
        memo
      end
    end
    hands
  end
end

class AlreadyInGameError < StandardError; end
class NotInGameError < StandardError; end
class NotGameOwnerError < StandardError; end
class GameAlreadyStartedError < StandardError; end
