module Projections
  module Mongo
    class InstructionCard
      include Mongoid::Document

      embedded_in :game, class_name: 'Projections::Mongo::Game'

      field :action, type: String
      field :amount, type: Integer
      field :priority, type: Integer
    end
  end
end
