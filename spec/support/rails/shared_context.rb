RSpec.shared_context "Given events", type: %r(controller|feature) do
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

RSpec.shared_context "API Controllers", file_path: %r(controllers/api) do
  def get(action, *args)
    params = args.first || {}
    token = case
              when defined?(access_token) then access_token
              when defined?(player) then player.access_token
              else nil
            end
    params = params.merge(access_token: token) if token
    params = params.merge(format: :json)
    super(action, params)
  end
end
