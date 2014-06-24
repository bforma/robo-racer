class GameUnit < Struct.new(:x, :y, :facing) 
  UP = 0
  RIGHT = 90
  DOWN = 180
  LEFT = 270

  def move(amount)
    self.class.new(move_x(amount), move_y(amount), facing)
  end

  def push(direction)
    self.class.new(push_x(direction), push_y(direction), facing)
  end

  def rotate(amount)
    self.class.new(x, y, new_facing(amount))
  end

  def inspect
    "#{x},#{x} (#{facing})"
  end

private

  def move_x(amount)
    return x + amount if facing == RIGHT
    return x - amount if facing == LEFT
    x
  end

  def move_y(amount)
    return y - amount if facing == UP
    return y + amount if facing == DOWN
    y
  end

  def push_x(direction)
    return x + 1 if direction == RIGHT
    return x - 1 if direction == LEFT
    x
  end

  def push_y(direction)
    return x - 1 if direction == UP
    return x + 1 if direction == DOWN
    y
  end

  def new_facing(amount)
    (facing + amount) % 360
  end

end
