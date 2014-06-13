require 'domain_helper'

describe RoboRacer::CommandHandlers::Game, type: :command_handlers do
  let(:id) { new_uuid }

  describe CreateGameCommand do
    let(:command) { CreateGameCommand.new(id: id) }

    specify do
      when_command command
      then_events GameCreatedEvent.new(id)
    end
  end

  describe MoveRobotCommand do
    let(:command) { MoveRobotCommand.new(id: id, speed: 1) }

    context "validations" do
      it { should ensure_inclusion_of(:speed).in_array(MoveRobotCommand::SPEEDS) }
    end

    context "dispatch" do
      before do
        dispatch(build(:create_game_command, id: id))
      end

      specify do
        expect { dispatch(command) }.
          to change { event_store.recorded_events.map(&:payload) }.
          by([RobotMovedEvent.new(id, GameUnit.new(1, 0, GameUnit::RIGHT))])
      end
    end
  end
end

