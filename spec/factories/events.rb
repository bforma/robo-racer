FactoryGirl.define do
  sequence :id do
    SecureRandom.uuid
  end

  factory :player_created do
    id
    name "Bob"
    email "bob@localhost.local"
    password "secret"
  end
end
