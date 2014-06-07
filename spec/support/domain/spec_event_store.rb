class SpecEventStore < Fountain::EventStore::EventStore
  attr_reader :recorded_events

  def initialize
    @recorded_events = []
  end

  def load_slice(stream_type, stream_id, first, last = -1)
    raise NoMethodError, "Not yet implemented"
  end

  def load_all(stream_type, stream_id)
    raise NoMethodError, "Not yet implemented"
  end

  def append(stream_type, stream_id, events)
    @recorded_events.concat(events)
  end
end
