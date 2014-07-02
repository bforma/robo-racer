class Checkpoint
  include Mongoid::Document

  embedded_in :board

  field :x, type: Integer
  field :y, type: Integer
  field :priority, type: Integer
end
