class Game
  include Mongoid::Document

  field :state, type: String
  field :host_id, type: String
end
