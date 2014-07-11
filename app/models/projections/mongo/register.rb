module Projections
  module Mongo
    class Register
      include Mongoid::Document

      embeds_one :instruction_card, class_name: 'Projections::Mongo::InstructionCard'
    end
  end
end
