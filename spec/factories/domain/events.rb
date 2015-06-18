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

    after :build do |o|
      o.password = BCrypt::Password.create(o.password)
    end
  end

  factory :game_created_event do
    id
    state { GameState::LOBBYING }
    host_id "bob"
  end

  factory :all_robots_programmed_event do
    id
  end
end
