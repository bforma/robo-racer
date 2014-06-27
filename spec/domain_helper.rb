ENV["RAILS_ENV"] ||= 'test'

require 'require_all'
require_relative '../domain/domain'
require_all 'spec/support/domain'
require 'shoulda/matchers'
require 'rspec/its'

I18n.enforce_available_locales = false

RSpec.configure do |config|
end

