require 'domain_helper'

describe GameCommandHandler, type: :command_handlers do
  let(:id) { new_uuid }

  describe CreateGameCommand do
    it_behaves_like "an event publisher" do
      let(:command) { CreateGameCommand.new(id: id) }
      let(:expected_events) do
        [GameCreatedEvent.new(id, GameState::LOBBYING, [])]
      end
    end
  end

  describe MoveRobotCommand do
    let(:command) { MoveRobotCommand.new(id: id, speed: 1) }

    describe "validations" do
      it { should ensure_inclusion_of(:speed).in_array(MoveRobotCommand::SPEEDS) }
    end

    describe "dispatch" do
      it_behaves_like "an event publisher" do
        before do
          dispatch(build(:create_game_command, id: id))
        end

        let(:expected_events) do
          [RobotMovedEvent.new(id, GameUnit.new(1, 0, GameUnit::RIGHT))]
        end
      end
    end
  end
end

