module Projections
  module Mongo
    class Robot
      include Mongoid::Document

      embedded_in :board, class_name: 'Projections::Mongo::Board'

      field :player_id, type: String
      field :x, type: Integer
      field :y, type: Integer
    end
  end
end
