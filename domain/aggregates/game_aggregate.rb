class GameAggregate < BaseAggregate
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

    apply GameStartedEvent.new(id, GameState::RUNNING)
  end

  def move_robot(speed)
    apply RobotMovedEvent.new(id, @robot.move(speed))
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
  end
end

class AlreadyInGameError < StandardError; end
class NotInGameError < StandardError; end
class NotGameOwnerError < StandardError; end
class GameAlreadyStartedError < StandardError; end
