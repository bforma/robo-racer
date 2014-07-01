FactoryGirl.define do
  sequence :id do
    SecureRandom.uuid
  end

  factory :player_created_event do
    id
    name "Bob"
    email "bob@localhost.local"
    password "secret"
    access_token { SecureRandom.hex }
  end

  factory :game_created_event do
    id
    state { GameState::LOBBYING }
    host_id { generate(:id) }
  end

  factory :player_joined_game_event do
    id
    player_id { generate(:id) }
  end

  factory :player_left_game_event do
    id
    player_id { generate(:id) }
  end
end
