class PlayerAggregate < BaseAggregate
  def initialize(id, name, email, password, access_token)
    apply PlayerWasCreated.new(id, name, email, password, access_token)
  end

  route_event PlayerWasCreated do |event, _headers|
    @id = event.id
  end
end
