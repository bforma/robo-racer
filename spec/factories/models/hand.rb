FactoryGirl.define do
  factory :hand, class: Projections::Mongo::Hand do
    player_id "bob"

    trait :with_card do
      instruction_cards { [build(:instruction_card)] }
    end
  end
end
