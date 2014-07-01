FactoryGirl.define do
  factory :game do
    state { GameState::LOBBYING }
    host_id { generate(:id) }
    player_ids { Array.new }

    trait :with_player do
      player_ids { [generate(:id)] }
    end
  end
end
