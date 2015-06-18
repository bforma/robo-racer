source "https://rubygems.org"

gem "rails"
gem "require_all"
gem "mongoid"
gem "bson_ext"
gem "devise"
gem "puma"
gem "memoist"

# background jobs
gem "sidekiq"
gem "sinatra", require: false
gem "slim"

# frontend
gem "sprockets", "~> 2.11.0"
gem "sass-rails"
gem "compass-rails"
gem "uglifier"
gem "coffee-rails"
gem "jquery-rails"
gem "haml"
gem "redcarpet"
gem "react-rails", "~> 0.13.0.0"
gem "font-awesome-rails"
gem "simple_form"

# event sourcing & CQRS
gem "fountain", github: "ianunruh/fountain"
gem "fountain-redis", github: "ianunruh/fountain-redis"
gem "redis"
gem "connection_pool"

group :development do
  gem "spring"
end

group :development, :test do
  gem "pry"
  gem "rspec-rails"
  gem "rspec-its"
  gem "coveralls", require: false
  gem "capybara"
  gem "capybara-webkit"
  gem "capybara-screenshot"
  gem "database_cleaner"
  gem "factory_girl_rails", "~> 4.0", require: false
end

group :test do
  gem "shoulda-matchers", require: false
  gem "json_spec"
end

