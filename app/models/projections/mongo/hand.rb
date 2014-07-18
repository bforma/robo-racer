module Projections
  module Mongo
    class Hand
      include Mongoid::Document

      embedded_in :contestant, class_name: 'Projections::Mongo::Contestant'
      embeds_many :instruction_cards, class_name: 'Projections::Mongo::InstructionCard'
    end
  end
end
