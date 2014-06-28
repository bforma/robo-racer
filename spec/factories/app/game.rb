FactoryGirl.define do
  factory :game do
    state { GameState::LOBBYING }
    host_id { generate(:id) }
    player_ids { Array.new }
  end
end
