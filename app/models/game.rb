class Game
  include Mongoid::Document

  field :state, type: String
  field :host_id, type: String
  field :player_ids, type: Array
end
