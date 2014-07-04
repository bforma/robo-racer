module Projections
  module Mongo
    class Tile
      include Mongoid::Document

      embedded_in :board, class_name: 'Projections::Mongo::Board'

      field :x, type: Integer
      field :y, type: Integer
    end
  end
end
