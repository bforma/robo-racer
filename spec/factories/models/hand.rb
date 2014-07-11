FactoryGirl.define do
  factory :hand, class: Projections::Mongo::Hand do
    player_id "bob"

    trait :with_cards do
      instruction_cards do
        [
          build(:instruction_card, priority: 10),
          build(:instruction_card, priority: 20)
        ]
      end
    end
  end
end
