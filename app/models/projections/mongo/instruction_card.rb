module Projections
  module Mongo
    class InstructionCard
      include Mongoid::Document

      embedded_in :hand, class_name: 'Projections::Mongo::Hand'
      embedded_in :program, class_name: 'Projections::Mongo::Program'

      field :action, type: String
      field :amount, type: Integer
      field :priority, type: Integer
    end
  end
end
