module Projections
  module Mongo
    class InstructionCard
      include Mongoid::Document

      field :action, type: String
      field :amount, type: Integer
      field :priority, type: Integer
    end
  end
end
