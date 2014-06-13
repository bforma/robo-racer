ENV["RAILS_ENV"] ||= 'test'

require 'require_all'
require_relative '../domain/domain'
require_all 'spec/support/domain'
require 'shoulda/matchers'

I18n.enforce_available_locales = false

RSpec.configure do |config|
  config.include CommandHandlerHelper, type: :command_handlers
  config.include DomainHelper
end

