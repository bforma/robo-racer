module Projections
  module Mongo
    class Program
      include Mongoid::Document

      embedded_in :game, class_name: 'Projections::Mongo::Contestant'
      embeds_many :instruction_cards, class_name: 'Projections::Mongo::InstructionCard'
    end
  end
end
