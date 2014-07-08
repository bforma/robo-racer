FactoryGirl.define do
  factory :instruction_card, class: Projections::Mongo::InstructionCard do
    action { InstructionCard::ROTATE }
    amount { InstructionCard::U_TURN }
    priority 10
  end
end
