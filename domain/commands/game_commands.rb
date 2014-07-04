class CreateGameCommand < Command
end

class JoinGameCommand < Command
end

class LeaveGameCommand < Command
end

class StartGameCommand < Command
end

class ProgramRobotCommand < Command
  INSTRUCTION_REGISTER_COUNT = 5

  attr_accessor :instruction_cards

  validates_length_of :instruction_cards, is: INSTRUCTION_REGISTER_COUNT
end

class PlayCurrentRoundCommand < BaseCommand
end
