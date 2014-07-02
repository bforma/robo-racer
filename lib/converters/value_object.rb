module Converters
  module ValueObject
    def to_model(value_object)
      send("to_#{value_object.class.name.underscore}", value_object)
    end

  private

    def to_board_tile(tile)
      Tile.new(x: tile.x, y: tile.y)
    end
  end
end
