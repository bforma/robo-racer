ENV["RAILS_ENV"] ||= 'test'

require 'require_all'
require_relative '../domain/domain'
require_all 'spec/support/domain'

RSpec.configure do |config|
  config.include CommandHandlerHelper, type: :command_handlers
  config.include DomainHelper
end
