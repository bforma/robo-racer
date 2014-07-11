module Projections
  module Mongo
    class Program
      include Mongoid::Document

      embedded_in :game, class_name: 'Projections::Mongo::Game'

      field :player_id, type: String

      embeds_many :registers, class_name: 'Projections::Mongo::Register'
    end
  end
end
