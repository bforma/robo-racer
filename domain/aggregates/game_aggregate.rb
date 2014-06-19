class GameAggregate < BaseAggregate
  MAX_HAND_SIZE = 9

  child_entities :instruction_deck

  def initialize(id, host_id)
    apply GameCreatedEvent.new(id, GameState::LOBBYING, host_id)
    apply PlayerJoinedGameEvent.new(id, host_id)
  end

  def join(player_id)
    raise GameAlreadyStartedError if @state == GameState::RUNNING
    raise PlayerAlreadyInGameError if @player_ids.include?(player_id)

    apply PlayerJoinedGameEvent.new(id, player_id)
  end

  def leave(player_id)
    raise GameAlreadyStartedError if @state == GameState::RUNNING
    raise PlayerNotInGameError unless @player_ids.include?(player_id)

    apply PlayerLeftGameEvent.new(id, player_id)
  end

  def start(player_id)
    raise PlayerNotGameHostError if @host_id != player_id
    raise GameAlreadyStartedError if @state == GameState::RUNNING

    apply GameStartedEvent.new(
      id, GameState::RUNNING, InstructionDeck.compose
    )

    start_round
  end

  def program_robot(player_id, instruction_cards)
    raise PlayerNotInGameError unless @player_ids.include?(player_id)
    raise GameNotRunningError unless @state == GameState::RUNNING
    raise RobotAlreadyProgrammedError if @programmed_robots.include?(player_id)

    hand = @hands[player_id]
    instruction_cards.each do |instruction_card|
      raise IllegalInstructionCardError unless hand.include?(instruction_card)
    end

    apply RobotProgrammedEvent.new(id, player_id, instruction_cards)
  end

  def move_robot(speed)
    apply RobotMovedEvent.new(id, @robot.move(speed))
  end

  class Dealer
    def initialize(deck, players)
      @deck = deck
      @players = players
    end

    def deal(count)
      count.times do
        @players.each do |player|
          @deck.deal_card(player)
        end
      end
    end
  end

private

  def start_round
    apply GameRoundStartedEvent.new(
      id, GameRound.new(1, Time.current, 1.minute.from_now)
    )

    dealer = Dealer.new(@instruction_deck, @player_ids)
    dealer.deal(MAX_HAND_SIZE)
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
    @instruction_deck = InstructionDeckEntity.new(event.instruction_deck)
  end

  route_event GameRoundStartedEvent do |event|
    @hands = Hash.new(Array.new)
    @programmed_robots = Array.new
  end

  route_event InstructionCardDealtEvent do |event|
    @hands[event.player_id] << event.instruction_card
  end

  route_event RobotProgrammedEvent do |event|
    @programmed_robots << event.player_id
  end
end

PlayerAlreadyInGameError = Class.new(StandardError)
PlayerNotInGameError = Class.new(StandardError)
PlayerNotGameHostError = Class.new(StandardError)
GameAlreadyStartedError = Class.new(StandardError)
GameNotRunningError = Class.new(StandardError)
IllegalInstructionCardError = Class.new(StandardError)
RobotAlreadyProgrammedError = Class.new(StandardError)

class InstructionDeck
  DECK_COMPOSITION = [
    {type: :u_turn, count: 6, start: 10, step: 10},
    {type: :rotate_left, count: 18, start: 70, step: 20},
    {type: :rotate_right, count: 18, start: 80, step: 20},
    {type: :back_up, count: 6, start: 430, step: 10},
    {type: :move_1, count: 18, start: 490, step: 10},
    {type: :move_2, count: 12, start: 670, step: 10},
    {type: :move_3, count: 6, start: 790, step: 10},
  ]

  def self.compose
    DECK_COMPOSITION.reduce([]) do |deck, card|
      card[:count].times do |n| # n starts at 0
        priority = card[:start] + n * card[:step]
        deck << InstructionCard.send(card[:type], priority)
      end

      deck
    end
  end
end
