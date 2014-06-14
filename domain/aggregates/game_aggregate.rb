class GameAggregate < BaseAggregate
  def initialize(id)
    apply GameCreatedEvent.new(id, GameState::LOBBYING, [])
  end

  def move_robot(speed)
    apply RobotMovedEvent.new(id, @robot.move(speed))
  end

  route_event GameCreatedEvent do |event|
    @id = event.id
    @state = event.state
    @player_ids = event.player_ids
    @robot = GameUnit.new(0, 0, GameUnit::RIGHT)
  end
end
