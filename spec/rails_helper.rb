# This file is copied to spec/ when you run "rails generate rspec:install"
ENV["RAILS_ENV"] ||= "test"
require "spec_helper"
require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "capybara/rails"
require "capybara/rspec"
require "capybara-screenshot/rspec"
require "database_cleaner"
require_all "spec/support/rails"
require "factory_girl"
require "sidekiq/testing"

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.include Warden::Test::Helpers, type: :feature
  config.include Devise::TestHelpers, type: :controller

  config.include AuthenticationHelper
  config.include AuthenticationHelper::Feature, type: :feature
  config.include AuthenticationHelper::Controller, type: :controller

  config.before(:suite) { FactoryGirl.reload }

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  DatabaseCleaner[:mongoid].strategy = :truncation
  DatabaseCleaner[:redis, {connection: Redis::Configuration.url}].strategy = :truncation

  config.before { DatabaseCleaner.start }
  config.after { DatabaseCleaner.clean }

  config.before(:each) do
    Sidekiq::Worker.clear_all
  end

  config.around(:each) do |example|
    if example.metadata[:sidekiq] == :fake
      Sidekiq::Testing.fake!(&example)
    elsif example.metadata[:sidekiq] == :inline
      Sidekiq::Testing.inline!(&example)
    elsif example.metadata[:type] == :feature
      Sidekiq::Testing.inline!(&example)
    else
      Sidekiq::Testing.fake!(&example)
    end
  end

  Capybara.javascript_driver = :webkit
  config.after :each, :js do
    page.driver.error_messages.each do |message|
      puts message
    end
  end

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
end
