module CommandHandlerHelper
  def self.included(_)
    require 'domain/command_handlers/shared_context'
  end
end
