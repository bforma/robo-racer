require "rails_helper"

describe AsyncEventListener do
  let(:listener) { AsyncEventListener.new }
  let(:handle_event) do
    listener.call(Fountain::Envelope.as_envelope(event))
  end

  describe AllRobotsProgrammed do
    let(:event) { build(:all_robots_programmed) }

    specify do
      expect { handle_event }.to change(PlayCurrentRoundJob.jobs, :size).by(1)
    end
  end
end
