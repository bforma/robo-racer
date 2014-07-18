FactoryGirl.define do
  factory :contestant, class: Projections::Mongo::Contestant do
    player_id "bob"
  end
end
