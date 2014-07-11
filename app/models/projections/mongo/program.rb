module Projections
  module Mongo
    class Program
      include Mongoid::Document

      embedded_in :game, class_name: 'Projections::Mongo::Game'

      field :player_id, type: String

      embeds_many :instruction_cards, class_name: 'Projections::Mongo::InstructionCard'
    end
  end
end
