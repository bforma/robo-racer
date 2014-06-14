class CreateGameCommand < Command
end

class JoinGameCommand < Command
end

class LeaveGameCommand < Command
end

class StartGameCommand < Command
end

class MoveRobotCommand < Command
  SPEEDS = [-1, 1]

  attr_accessor :speed

  validates_inclusion_of :speed, in: SPEEDS
end
