class Spawn
  include Mongoid::Document

  embedded_in :board

  field :player_id, type: String
  field :x, type: Integer
  field :y, type: Integer
  field :facing, type: Integer
end
