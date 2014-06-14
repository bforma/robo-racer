class CreateGameCommand < BaseCommand
end

class MoveRobotCommand < BaseCommand
  SPEEDS = [-1, 1]

  attr_accessor :speed

  validates_inclusion_of :speed, in: SPEEDS
end
