FactoryGirl.define do
  factory :spawn, class: Projections::Mongo::Spawn do
    player_id "bob"
    x 0
    y 0
    facing GameUnit::DOWN
  end
end
