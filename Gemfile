source 'https://rubygems.org'

gem 'rails'
gem 'require_all'
gem 'mongoid', '~> 4.0.0.rc1', github: 'mongoid/mongoid'
gem 'bson_ext'
gem 'devise'

# frontend
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'haml'
gem 'react-rails'

# event sourcing & CQRS
gem 'fountain', github: 'ianunruh/fountain'
gem 'fountain-redis', github: 'ianunruh/fountain-redis'
gem 'redis'
gem 'connection_pool'

group :development do
  gem 'spring'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'coveralls', require: false
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4.0', require: false
end

group :test do
  gem 'shoulda-matchers', require: false
end

