RSpec.shared_context "Given events", type: %r(controller|feature) do
  let!(:gateway) { GatewayBuilder.build }
  let(:event_store) { gateway.event_store }
  let(:event_bus) { gateway.event_bus }

  let(:journals) { Hash.new }

  def given_events(events_per_aggregate_type)
    events_per_aggregate_type.each do |aggregate_type, events|
      stream_id = events.first.id

      journal = journals[stream_id]
      unless journal
        journal = Fountain::Domain::Journal.new
        journals[stream_id] = journal
      end
      events = events.map { |event| journal.push(event, {}) }
      event_store.append(aggregate_type.to_s, stream_id, events)

      event_bus.publish(events)
    end
  end
end

RSpec.shared_context "API Controllers", file_path: %r(controllers/api) do
  def get(action, *args)
    super(action, enrich_request(args))
  end

  def post(action, *args)
    super(action, enrich_request(args))
  end

  def put(action, *args)
    super(action, enrich_request(args))
  end

  def delete(action, *args)
    super(action, enrich_request(args))
  end

  def head(action, *args)
    super(action, enrich_request(args))
  end

  def enrich_request(args)
    params = args.first || {}
    params = params.merge(access_token: access_token) if defined?(access_token)
    params = params.merge(access_token: player.access_token) if defined?(player)
    params.merge(format: :json)
  end
end
