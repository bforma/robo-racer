RSpec.shared_context "Capybara", type: :feature do
  let!(:gateway) { RoboRacer::Gateway.build }
  let(:event_store) { gateway.event_store }
  let(:event_bus) { gateway.event_bus }

  let(:journal) { Fountain::Domain::Journal.new }

  def given_events(events_per_aggregate_type)
    events_per_aggregate_type.each do |aggregate_type, events|
      stream_id = events.first.id

      events = events.map { |event| journal.push(event, {}) }
      event_store.append(aggregate_type.to_s, stream_id, events)

      event_bus.publish(events)
    end
  end
end
