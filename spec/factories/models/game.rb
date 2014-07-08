FactoryGirl.define do
  factory :game, class: Projections::Mongo::Game do
    state { GameState::LOBBYING }
    host_id { generate(:id) }
    player_ids { Array.new }

    trait :with_player do
      player_ids { ["bob"] }
    end

    trait :starting do
      state { GameState::RUNNING }
      with_player
      board { build(:board) }
      instruction_deck_size 84
    end

    trait :started do
      board { build(:board, :round_1) }
      hands { [build(:hand, :with_card)] }
    end
  end
end
