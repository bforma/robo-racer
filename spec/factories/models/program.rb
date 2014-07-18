FactoryGirl.define do
  factory :program, class: "Projections::Mongo::Program" do
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
