FactoryGirl.define do
  factory :board, class: Projections::Mongo::Board do
    trait :round_1 do
      tiles do
        [
          build(:tile, x: 0, y: 0),
          build(:tile, x: 1, y: 0),
          build(:tile, x: 0, y: 1),
          build(:tile, x: 1, y: 1)
        ]
      end

      spawns { build_list(:spawn, 1) }
      checkpoints { build_list(:checkpoint, 1) }
      robots { build_list(:robot, 1) }
    end
  end
end
