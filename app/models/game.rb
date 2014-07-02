class Game
  include Mongoid::Document

  embeds_one :board
  embeds_many :hands

  field :state, type: String
  field :host_id, type: String
  field :player_ids, type: Array
  field :instruction_deck_size, type: Integer
  field :round_number, type: Integer
end
