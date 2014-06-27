class PlayerAggregate < BaseAggregate
  def initialize(id, name, email, password)
    apply PlayerCreatedEvent.new(id, name, email, password)
  end

  route_event PlayerCreatedEvent do |event, headers|
    @id = event.id
  end
end
