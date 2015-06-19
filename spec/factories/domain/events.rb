FactoryGirl.define do
  sequence :id do
    SecureRandom.uuid
  end

  factory :player_was_created do
    id
    name "Bob"
    email "bob@localhost.local"
    password "secret"
    access_token { SecureRandom.hex }

    after :build do |o|
      o.password = BCrypt::Password.create(o.password)
    end
  end

  factory :game_was_created do
    id
    state { GameState::LOBBYING }
    host_id "bob"
  end

  factory :all_robots_programmed do
    id
  end
end
