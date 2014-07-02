class Tile
  include Mongoid::Document

  embedded_in :board

  field :x, type: Integer
  field :y, type: Integer
end
