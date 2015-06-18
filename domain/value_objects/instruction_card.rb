class InstructionCard < Struct.new(:action, :amount, :priority)
  ROTATE = "R"
  MOVE = "M"

  LEFT = -90
  RIGHT = 90
  U_TURN = 180

  ONE = 1
  TWO = 2
  THREE = 3
  BACK_UP = -1

  def rotate?
    action == ROTATE
  end

  def move?
    action == MOVE
  end

  def inspect
    "#{action}#{amount} (#{priority})"
  end

  class << self
    def u_turn(priority)
      new(ROTATE, U_TURN, priority)
    end

    def rotate_left(priority)
      new(ROTATE, LEFT, priority)
    end

    def rotate_right(priority)
      new(ROTATE, RIGHT, priority)
    end

    def back_up(priority)
      new(MOVE, BACK_UP, priority)
    end

    def move_1(priority)
      new(MOVE, ONE, priority)
    end

    def move_2(priority)
      new(MOVE, TWO, priority)
    end

    def move_3(priority)
      new(MOVE, THREE, priority)
    end
  end
end
