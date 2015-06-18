class SpecEventStore < Fountain::EventStore::MemoryEventStore
  attr_reader :recorded_events

  def initialize
    @recorded_events = []
    super
  end

  alias_method :super_append, :append
  def given_events(stream_type, stream_id, events)
    super_append(stream_type, stream_id, events)
  end

  def append(stream_type, stream_id, events)
    @recorded_events.concat(events)
    super
  end
end
