class BoardEntity < BaseEntity

  inheritable_accessor :event_router do
    Fountain::Router.create_router
  end

  def initialize(tiles)
    @tiles = tiles
    @spawns = Hash.new
    @goals = Hash.new
    @robots = Hash.new

    @last_touched_goals = Hash.new(0)
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

  def touch_goals
    each_player_at_goal do |player_id, goal, _|
      if next_goal_for_player?(player_id, goal)
        apply GoalTouchedEvent.new(id, player_id, goal)

        if player_touched_final_goal?(player_id)
          apply PlayerWonGameEvent.new(id, player_id)
        end
      end
    end
  end

  def replace_spawns
    each_player_at_goal do |player_id, goal, robot|
      apply SpawnReplacedEvent.new(
        id,
        player_id,
        GameUnit.new(goal.x, goal.y, robot.facing)
      )
    end
  end

  route_event SpawnPlacedEvent do |event|
    @spawns[event.player_id] = event.spawn
  end

  route_event GoalPlacedEvent do |event|
    @goals[event.goal.priority] = event.goal
    @final_goal = @goals.values.map(&:priority).max
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

  route_event GoalTouchedEvent do |event|
    @last_touched_goals[event.player_id] = event.goal.priority
  end

  route_event SpawnReplacedEvent do |event|
    @spawns[event.player_id] = event.spawn
  end

private

  def off_board?(position)
    tile_at(position.x, position.y).nil?
  end

  def tile_at(x, y)
    @tiles["#{x},#{y}"]
  end

  def robot_at(position)
    @robots.find do |_, robot|
      robot.x == position.x && robot.y == position.y
    end
  end

  def goal_at(position)
    @goals.find do |_, goal|
      goal.x == position.x && goal.y == position.y
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

  def each_player_at_goal
    @robots.each do |player_id, robot|
      _, goal = goal_at(robot)
      yield(player_id, goal, robot) if goal
    end
  end

  def next_goal_for_player?(player_id, goal)
    (@last_touched_goals[player_id] + 1) == goal.priority
  end

  def player_touched_final_goal?(player_id)
    @last_touched_goals[player_id] == @final_goal
  end

end

IllegalLocationError = Class.new(StandardError)
SpawnAlreadyPlacedError = Class.new(StandardError)
GoalAlreadyPlacedError = Class.new(StandardError)
