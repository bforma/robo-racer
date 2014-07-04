FactoryGirl.define do
  factory :board, class: Projections::Mongo::Board do
    tiles do
      [
        Projections::Mongo::Tile.new(x: 0, y: 0),
        Projections::Mongo::Tile.new(x: 1, y: 0),
        Projections::Mongo::Tile.new(x: 0, y: 1),
        Projections::Mongo::Tile.new(x: 1, y: 1),
      ]
    end
  end
end
