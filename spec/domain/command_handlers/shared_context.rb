RSpec.shared_context RoboRacer::CommandHandlers, type: :command_handlers do
  let(:event_store) { SpecEventStore.new }
  let(:command_bus) { RoboRacer::Configuration.wire_up(event_store) }

  before do
    Fountain.configure do |config|
      config.logger = Logger.new($stdout)
      config.logger.level = Logger::INFO
    end
  end

  def given_events(*events)
    raise NoMethodError, "Not yet implemented"
  end

  def when_command(command)
    command_bus.dispatch(
      Fountain::Envelope.as_envelope(command),
      DefaultCommandCallback.new
    )
  end

  def then_events(*events)
    actual_events = event_store.recorded_events.map(&:payload)
    expect(actual_events.map(&:class)).to eq(events.map(&:class))
    actual_events.zip(events).each do |actual, expected|
      expect(actual).to eq(expected) if expected
    end
  end
end
