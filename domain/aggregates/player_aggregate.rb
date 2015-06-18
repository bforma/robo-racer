class PlayerAggregate < BaseAggregate
  def initialize(id, name, email, password, access_token)
    apply PlayerCreatedEvent.new(id, name, email, password, access_token)
  end

  route_event PlayerCreatedEvent do |event, _headers|
    @id = event.id
  end
end
