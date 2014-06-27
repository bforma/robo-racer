FactoryGirl.define do
  sequence :id do
    SecureRandom.uuid
  end

  factory :player_created_event do
    id
    name "Bob"
    email "bob@localhost.local"
    password "secret"
  end

  factory :game_created_event do
    id
    state { GameState::LOBBYING }
    host_id { id }
  end
end
