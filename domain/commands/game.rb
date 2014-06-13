class CreateGameCommand < RoboRacer::Command::Base
end

class MoveRobotCommand < RoboRacer::Command::Base
  SPEEDS = [-1, 1]

  attr_accessor :speed

  validates_inclusion_of :speed, in: SPEEDS
end
