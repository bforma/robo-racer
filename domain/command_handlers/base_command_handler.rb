class BaseCommandHandler
  include Fountain::Command::Handler

  attr_reader :repository

  def initialize(repository)
    @repository = repository
  end
end
