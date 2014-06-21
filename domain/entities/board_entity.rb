class BoardEntity < BaseEntity

  inheritable_accessor :event_router do
    Fountain::Router.create_router
  end

  def initialize(tiles)
    @tiles = tiles
    @spawns = Hash.new
    @goals = Hash.new
    @robots = Hash.new
  end

  def place_spawn(spawn, player_id)
    raise SpawnAlreadyPlacedError if @spawns[player_id]
    raise IllegalLocationError unless valid_location?(spawn)

    apply SpawnPlacedEvent.new(id, player_id, spawn)
  end

  def place_goal(goal)
    raise GoalAlreadyPlacedError if @goals.key?(goal.priority)
    raise IllegalLocationError unless valid_location?(goal)

    apply GoalPlacedEvent.new(id, goal)
  end

  def spawn_players
    @spawns.each do |player_id, spawn|
      apply RobotSpawnedEvent.new(
        id,
        player_id,
        GameUnit.new(spawn.x, spawn.y, spawn.facing)
      )
    end
  end

  def instruct_robot(player_id, instruction_card)
    case
      when instruction_card.move?
        move_robot(player_id, instruction_card)
      when instruction_card.rotate?
        rotate_robot(player_id, instruction_card)
    end
  end

  route_event SpawnPlacedEvent do |event|
    @spawns[event.player_id] = event.spawn
  end

  route_event GoalPlacedEvent do |event|
    @goals[event.goal.priority] = event.goal
  end

  route_event RobotSpawnedEvent do |event|
    @robots[event.player_id] = event.robot
  end

  route_event RobotMovedEvent do |event|
    @robots[event.player_id] = event.robot
  end

  route_event RobotRotatedEvent do |event|
    @robots[event.player_id] = event.robot
  end

private

  def valid_location?(location)
    tile_at(location.x, location.y).present?
  end

  def tile_at(x, y)
    @tiles["#{x},#{y}"]
  end

  def move_robot(player_id, instruction_card)
    robot = @robots[player_id]
    apply RobotMovedEvent.new(
      id,
      player_id,
      robot.move(instruction_card.amount)
    )
  end

  def rotate_robot(player_id, instruction_card)
    robot = @robots[player_id]
    apply RobotRotatedEvent.new(
      id,
      player_id,
      robot.rotate(instruction_card.amount)
    )
  end

end

IllegalLocationError = Class.new(StandardError)
SpawnAlreadyPlacedError = Class.new(StandardError)
GoalAlreadyPlacedError = Class.new(StandardError)
