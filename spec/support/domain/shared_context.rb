RSpec.shared_context "CommandHandlers", type: :command_handlers do
  let(:event_store) { SpecEventStore.new }
  let(:gateway) { RoboRacer::Gateway.new(event_store) }
  let(:journal) { Fountain::Domain::Journal.new }

  before do
    Fountain.configure do |config|
      config.logger = Logger.new($stdout)
      config.logger.level = Logger::INFO
    end
  end

  def dispatch(command)
    gateway.dispatch(command)
  end

  def given_events(*events)
    stream_id = events.first.id
    events = events.map { |event| journal.push(event, {}) }
    event_store.append("GameAggregate", stream_id, events)
  end
end

class StubAggregateRoot
  attr_reader :id, :recorded_events

  def initialize(id)
    @id = id
    @recorded_events = Array.new
  end

  def entity=(entity)
    @entity = entity
    @entity.aggregate_root = self
  end

  def apply(event, _)
    @recorded_events << event
    @entity.handle(Fountain::Envelope.as_envelope(event))
  end
end

RSpec.shared_context "Entities", type: :entities do
  let(:id) { new_uuid }
  let(:event_recorder) { StubAggregateRoot.new(id) }
  before { event_recorder.entity = entity }

  def given_events(*events)
    events.each do |event|
      entity.handle(Fountain::Envelope.as_envelope(event))
    end
  end

  def expect_events(*expected_events)
    expect { subject }.
      to change { event_recorder.recorded_events }.
      by(expected_events)
  end

  def expect_no_events
    expect { subject }.to_not change { event_recorder.recorded_events }
  end
end

RSpec.shared_examples "an event publisher" do
  specify do
    expect { dispatch(command) }.
      to change { event_store.recorded_events.map(&:payload) }.
      by(expected_events)
  end
end
