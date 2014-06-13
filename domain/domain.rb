require 'active_model'

require 'fountain'
require 'require_all'

require_all 'domain/helpers'
require_all 'domain/value_objects'
require_all 'domain/commands'
require_all 'domain/events'
require_all 'domain/aggregates'
require_all 'domain/command_handlers'

require_relative 'configuration'
require_relative 'default_command_callback'

