class Hand
  include Mongoid::Document

  embedded_in :game

  field :player_id, type: String
  field :size, type: Integer
end
