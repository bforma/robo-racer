module Projections
  module Mongo
    class Game
      include Mongoid::Document

      embeds_one :board, class_name: 'Projections::Mongo::Board'
      embeds_many :players, class_name: 'Projections::Mongo::Contestant'

      field :state, type: String
      field :host_id, type: String
      field :player_ids, type: Array
      field :instruction_deck_size, type: Integer
      field :round_number, type: Integer
    end
  end
end
