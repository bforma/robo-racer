class SpecEventStore < Fountain::EventStore::MemoryEventStore
  attr_reader :recorded_events

  def initialize
    @recorded_events = []
    super
  end

  def append(stream_type, stream_id, events)
    @recorded_events.concat(events)
    super
  end
end
