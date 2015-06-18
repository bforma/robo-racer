class BaseCommandHandler
  include Fountain::Command::Handler

  attr_reader :repository

  def initialize(repository)
    @repository = repository
  end

  private

  def with_aggregate(id)
    aggregate = repository.load(id)
    yield(aggregate)
  end
end
