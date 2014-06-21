class GameUnit < Struct.new(:x, :y, :facing) 
  UP = 0
  RIGHT = 90
  DOWN = 180
  LEFT = 270

  def move(amount)
    self.class.new(new_x(amount), new_y(amount), facing)
  end

  def rotate(amount)
    self.class.new(x, y, new_facing(amount))
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

  def new_facing(amount)
    (facing + amount) % 360
  end

end
