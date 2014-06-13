class GameUnit < Struct.new(:x, :y, :facing) 
  UP = "u"
  DOWN = "d"
  LEFT = "l"
  RIGHT = "r"

  def move(amount)
    self.class.new(new_x(amount), new_y(amount), facing)
  end

private

  def new_x(amount)
    return x + amount if facing == RIGHT
    return x - amount if facing == LEFT
    x
  end

  def new_y(amount)
    return y - amount if facing == UP
    return y + amount if facing == DOWN
    y
  end

end
