BoardTile = Struct.new(:x, :y)
class BoardTile
  def inspect
    "#{x},#{y}"
  end
end
