require 'domain_helper'

module RoboRacer
  describe CommandHandlers::Player, type: :command_handlers do
    let(:uuid) { new_uuid }

    context CreatePlayer do
      specify do
        when_command CreatePlayer.new(uuid, "Bob", "secret", "secret")
        then_events PlayerCreated.new(uuid, "Bob", "secret")
      end
    end
  end
end
