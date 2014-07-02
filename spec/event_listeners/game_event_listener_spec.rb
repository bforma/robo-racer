require 'rails_helper'

describe GameEventListener do
  let(:listener) { GameEventListener.new }

  let(:handle_event) do
    listener.call(Fountain::Envelope.as_envelope(event))
  end

  let(:game_id) { new_uuid }
  let(:started_game) { create(:game, :started, _id: game_id) }

  describe GameCreatedEvent do
    let(:event) { build(:game_created_event) }

    specify do
      expect { handle_event }.to change { Game.count }.by(1)
    end
  end

  describe PlayerJoinedGameEvent do
    let(:event) { build(:player_joined_game_event, id: game_id) }
    let(:game) { create(:game, _id: game_id) }

    specify do
      expect { handle_event }.to change { game.reload.player_ids }.
        from([]).
        to([event.player_id])
    end
  end

  describe PlayerLeftGameEvent do
    let(:joined_player_id) { new_uuid }
    let(:event) do
      build(:player_left_game_event, id: game_id, player_id: joined_player_id)
    end
    let(:game) { create(:game, _id: game_id, player_ids: [joined_player_id]) }

    specify do
      expect { handle_event }.to change { game.reload.player_ids }.
        from(game.player_ids).
        to([])
    end
  end

  describe GameStartedEvent do
    let!(:game) { create(:game, :with_player, _id: game_id) }
    let(:event) { build(:game_started_event, id: game_id) }

    specify do
      expect { handle_event }.to change { game.reload.state }.
        from(GameState::LOBBYING).
        to(GameState::RUNNING)
    end

    specify do
      expect { handle_event }.to change { game.reload.instruction_deck_size }
        .to(84)
    end

    specify { expect { handle_event }.to change { game.reload.board } }

    context "tiles" do
      subject { game.reload.board.tiles }
      before { handle_event }

      its(:size) { is_expected.to eq(4) }

      [[0, 0], [1, 0], [0, 1], [1, 1]].each_with_index do |pos, n|
        context pos do
          subject { game.reload.board.tiles[n] }
          its(:x) { is_expected.to eq(pos[0]) }
          its(:y) { is_expected.to eq(pos[1]) }
        end
      end
    end
  end

  describe SpawnPlacedEvent do
    let!(:game) { started_game }
    let(:event) { build(:spawn_placed_event, id: game_id) }

    specify { expect { handle_event }.to change { game.reload.board.spawns } }

    context "attributes" do
      subject { game.reload.board.spawns.last }
      before { handle_event }

      its(:player_id) { is_expected.to eq(event.player_id) }
      its(:x) { is_expected.to eq(event.spawn.x) }
      its(:y) { is_expected.to eq(event.spawn.y) }
      its(:facing) { is_expected.to eq(event.spawn.facing) }
    end
  end

  describe GoalPlacedEvent do
    let!(:game) { started_game }
    let(:event) { build(:goal_placed_event, id: game_id) }

    specify { expect { handle_event }.to change { game.reload.board.checkpoints } }

    context "attributes" do
      subject { game.reload.board.checkpoints.last }
      before { handle_event }

      its(:x) { is_expected.to eq(event.goal.x) }
      its(:y) { is_expected.to eq(event.goal.y) }
      its(:priority) { is_expected.to eq(event.goal.priority) }
    end
  end

  describe RobotSpawnedEvent do
    let!(:game) { started_game }
    let(:event) { build(:robot_spawned_event, id: game_id) }

    specify { expect { handle_event }.to change { game.reload.board.robots } }

    context "attributes" do
      subject { game.reload.board.robots.last }
      before { handle_event }

      its(:player_id) { is_expected.to eq(event.player_id) }
      its(:x) { is_expected.to eq(event.robot.x) }
      its(:y) { is_expected.to eq(event.robot.y) }
    end
  end

  describe GameRoundStartedEvent do
    let!(:game) { started_game }
    let(:event) { build(:game_round_started_event, id: game_id) }

    specify do
      expect { handle_event }.to change { game.reload.round_number }.to(1)
    end

    context "given a previous round" do
      pending "perform cleanup"
    end
  end

  describe InstructionCardDealtEvent do
    let!(:game) { started_game }
    let(:event) { build(:instruction_card_dealt_event, id: game_id) }

    specify do
      expect { handle_event }.to change { game.reload.hands }
    end

    context "attributes" do
      subject { game.reload.hands.last }
      before { handle_event }

      its(:player_id) { is_expected.to eq(event.player_id) }
      its(:size) { is_expected.to eq(1) }
    end

    context "given a hand with cards" do
      pending
    end
  end
end
