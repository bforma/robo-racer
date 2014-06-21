class BoardTile < Struct.new(:x, :y)
  def inspect
    "#{x},#{y}"
  end
end
