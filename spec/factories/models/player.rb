FactoryGirl.define do
  factory :player do
    name "Bob"
    email "bob@localhost.local"
    password "secret"
    password_confirmation "secret"
    access_token { SecureRandom.hex }
  end
end
