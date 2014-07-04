module Projections
  module Mongo
    class Board
      include Mongoid::Document

      embedded_in :game, class_name: 'Projections::Mongo::Game'

      embeds_many :tiles, class_name: 'Projections::Mongo::Tile'
      embeds_many :spawns, class_name: 'Projections::Mongo::Spawn'
      embeds_many :checkpoints, class_name: 'Projections::Mongo::Checkpoint'
      embeds_many :robots, class_name: 'Projections::Mongo::Robot'
    end
  end
end
