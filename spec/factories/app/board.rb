FactoryGirl.define do
  factory :board do
    tiles do
      [
        Tile.new(x: 0, y: 0),
        Tile.new(x: 1, y: 0),
        Tile.new(x: 0, y: 1),
        Tile.new(x: 1, y: 1),
      ]
    end
  end
end
