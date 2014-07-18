module Projections
  module Mongo
    class Contestant
      include Mongoid::Document

      embedded_in :game, class_name: 'Projections::Mongo::Game'

      embeds_one :hand, class_name: 'Projections::Mongo::Hand'
      embeds_one :program, class_name: 'Projections::Mongo::Program'

      field :player_id, type: String

      after_initialize do |model|
        model.hand ||= model.build_hand
        model.program ||= model.build_program
      end
    end
  end
end
