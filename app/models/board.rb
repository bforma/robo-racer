class Board
  include Mongoid::Document

  embedded_in :game

  embeds_many :tiles
  embeds_many :spawns
  embeds_many :checkpoints
  embeds_many :robots
end
