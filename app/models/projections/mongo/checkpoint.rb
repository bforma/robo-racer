module Projections
  module Mongo
    class Checkpoint
      include Mongoid::Document

      embedded_in :board, class_name: 'Projections::Mongo::Board'

      field :x, type: Integer
      field :y, type: Integer
      field :priority, type: Integer
    end
  end
end
