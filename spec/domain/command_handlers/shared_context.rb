RSpec.shared_context "CommandHandlers", type: :command_handlers do
  let(:event_store) { SpecEventStore.new }
  let(:command_bus) { RoboRacer::Configuration.wire_up(event_store) }

  before do
    Fountain.configure do |config|
      config.logger = Logger.new($stdout)
      config.logger.level = Logger::INFO
    end
  end

  def dispatch(command)
    command_bus.dispatch(
      Fountain::Envelope.as_envelope(command),
      DefaultCommandCallback.new
    )
  end
end

RSpec.shared_examples "an event publisher" do
  specify do
    expect { dispatch(command) }.
      to change { event_store.recorded_events.map(&:payload) }.
           by(expected_events)
  end
end
