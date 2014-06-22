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
    raise IllegalLocationError if off_board?(spawn)

    apply SpawnPlacedEvent.new(id, player_id, spawn)
  end

  def place_goal(goal)
    raise GoalAlreadyPlacedError if @goals.key?(goal.priority)
    raise IllegalLocationError if off_board?(goal)

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
    if instruction_card.move?
      move_robot(player_id, instruction_card)
    elsif instruction_card.rotate?
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

  route_event RobotPushedEvent do |event|
    @robots[event.player_id] = event.robot
  end

  route_event RobotRotatedEvent do |event|
    @robots[event.player_id] = event.robot
  end

  route_event RobotDiedEvent do |event|
    @robots.delete(event.player_id)
  end

private

  def off_board?(position)
    tile_at(position.x, position.y).nil?
  end

  def tile_at(x, y)
    @tiles["#{x},#{y}"]
  end

  def robot_at(position)
    @robots.find do |player_id, robot|
      if robot.x == position.x && robot.y == position.y
        return [player_id, robot]
      end
    end
  end

  def move_robot(player_id, instruction_card)
    instruction_card.amount.abs.times do
      direction = [-1, instruction_card.amount, 1].sort[1]
      break unless step_robot(player_id, direction)
    end
  end

  def step_robot(player_id, direction)
    robot = @robots[player_id]
    new_position = robot.move(direction)
    other_robot = robot_at(new_position)
    push_robot(*other_robot, robot.facing) if other_robot
    apply RobotMovedEvent.new(id, player_id, new_position)

    if off_board?(new_position)
      apply RobotDiedEvent.new(id, player_id, new_position)
      return false
    end

    true
  end

  def push_robot(player_id, robot, direction)
    new_position = robot.push(direction)
    other_robot = robot_at(new_position)
    push_robot(*other_robot, direction) if other_robot
    apply RobotPushedEvent.new(id, player_id, new_position)

    if off_board?(new_position)
      apply RobotDiedEvent.new(id, player_id, new_position)
    end
  end

  def rotate_robot(player_id, instruction_card)
    robot = @robots[player_id]
    new_position = robot.rotate(instruction_card.amount)
    apply RobotRotatedEvent.new(id, player_id, new_position)
  end

end

IllegalLocationError = Class.new(StandardError)
SpawnAlreadyPlacedError = Class.new(StandardError)
GoalAlreadyPlacedError = Class.new(StandardError)
