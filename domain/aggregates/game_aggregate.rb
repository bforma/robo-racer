class GameAggregate < BaseAggregate
  MAX_HAND_SIZE = 9

  child_entities :instruction_deck, :board

  def initialize(id, host_id)
    apply GameCreatedEvent.new(id, GameState::LOBBYING, host_id)
    apply PlayerJoinedGameEvent.new(id, host_id)
  end

  def join(player_id)
    raise GameAlreadyStartedError if game_running?
    raise PlayerAlreadyInGameError if @player_ids.include?(player_id)

    apply PlayerJoinedGameEvent.new(id, player_id)
  end

  def leave(player_id)
    raise GameAlreadyStartedError if game_running?
    raise PlayerNotInGameError unless @player_ids.include?(player_id)

    apply PlayerLeftGameEvent.new(id, player_id)
  end

  def start(player_id)
    raise PlayerNotGameHostError if @host_id != player_id
    raise GameAlreadyStartedError if game_running?

    apply GameStartedEvent.new(
      id,
      GameState::RUNNING,
      InstructionDeckComposer.compose,
      BoardComposer.compose
    )

    place_spawns
    place_goals
    spawn_players
    start_new_round
  end

  def program_robot(player_id, instruction_cards)
    raise PlayerNotInGameError unless @player_ids.include?(player_id)
    raise GameNotRunningError unless game_running?
    raise RobotAlreadyProgrammedError if @robot_programs.key?(player_id)

    hand = @hands[player_id]
    instruction_cards.each do |instruction_card|
      raise IllegalInstructionCardError unless hand.include?(instruction_card)
    end

    apply RobotProgrammedEvent.new(id, player_id, instruction_cards)

    if @robot_programs.size == @player_ids.size
      apply AllRobotsProgrammedEvent.new(id)
    end
  end

  def play_current_round
    play_registers
    @board.touch_goals
    @board.replace_spawns
    discard_instruction_cards

    end_game if game_has_winner?
    start_new_round if game_running?
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

  def start_new_round
    apply GameRoundStartedEvent.new(id, GameRound.new(@game_round_number + 1))

    dealer = Dealer.new(@instruction_deck, @player_ids)
    dealer.deal(MAX_HAND_SIZE)
  end

  def place_spawns
    @player_ids.each_with_index do |player_id, index|
      @board.place_spawn(GameUnit.new(index + 2, 1, GameUnit::DOWN), player_id)
    end
  end

  def place_goals
    @board.place_goal(Goal.new(2, 11, 1))
    @board.place_goal(Goal.new(10, 7, 2))
  end

  def spawn_players
    @board.spawn_players
  end

  def play_registers
    @registers.each do |register|
      register.each do |robot_instruction|
        @board.instruct_robot(robot_instruction[0], robot_instruction[1])
      end
    end
  end

  def discard_instruction_cards
    @hands.values.flatten.each do |instruction_card|
      @instruction_deck.discard_card(instruction_card)
    end
  end

  def end_game
    apply GameEndedEvent.new(id, GameState::ENDED)
  end

  def game_has_winner?
    @winner
  end

  def game_running?
    @state == GameState::RUNNING
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
    @board = BoardEntity.new(event.tiles)
    @game_round_number = 0
  end

  route_event GameRoundStartedEvent do |event|
    @hands = Hash.new
    @robot_programs = Hash.new
    @registers = Array.new
    @game_round_number = event.game_round.number
  end

  route_event InstructionCardDealtEvent do |event|
    @hands[event.player_id] ||= Array.new
    @hands[event.player_id] << event.instruction_card
  end

  route_event RobotProgrammedEvent do |event|
    @robot_programs[event.player_id] = event.instruction_cards

    event.instruction_cards.each_with_index do |instruction_card, index|
      @registers[index] ||= Array.new
      @registers[index] << [event.player_id, instruction_card]
    end

    @registers.each do |register|
      register.sort_by! do |robot_instruction|
        robot_instruction[1].priority
      end
    end
  end

  route_event PlayerWonGameEvent do |event|
    @winner = event.player_id
  end

  route_event GameEndedEvent do |event|
    @state = event.state
  end
end

PlayerAlreadyInGameError = Class.new(StandardError)
PlayerNotInGameError = Class.new(StandardError)
PlayerNotGameHostError = Class.new(StandardError)
GameAlreadyStartedError = Class.new(StandardError)
GameNotRunningError = Class.new(StandardError)
IllegalInstructionCardError = Class.new(StandardError)
RobotAlreadyProgrammedError = Class.new(StandardError)

class InstructionDeckComposer
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

class BoardComposer
  DEFAULT_WIDTH = 12
  DEFAULT_HEIGHT = 12

  def self.compose(width = DEFAULT_WIDTH, height = DEFAULT_HEIGHT)
    (0..height - 1).reduce({}) do |memo, y|
      (0..width - 1).each do |x|
        memo["#{x},#{y}"] = BoardTile.new(x, y)
      end
      memo
    end
  end
end
