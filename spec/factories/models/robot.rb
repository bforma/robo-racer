FactoryGirl.define do
  factory :robot, class: Projections::Mongo::Robot do
    player_id "bob"
    x 0
    y 0
    facing GameUnit::DOWN
  end
end
