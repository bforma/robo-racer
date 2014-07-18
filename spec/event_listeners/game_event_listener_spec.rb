require 'rails_helper'

describe GameEventListener do
  let(:listener) { GameEventListener.new }

  let(:handle_event) do
    listener.call(Fountain::Envelope.as_envelope(event))
  end

  let(:game_id) { new_uuid }
  let(:starting_game) { create(:game, :starting, _id: game_id) }
  let(:started_game) { create(:game, :started, _id: game_id) }

  describe GameCreatedEvent do
    let(:event) { build(:game_created_event) }

    specify do
      expect { handle_event }.to change { Projections::Mongo::Game.count }.by(1)
    end
  end

  describe PlayerJoinedGameEvent do
    let(:event) { build(:player_joined_game_event, id: game_id) }
    let(:game) { create(:game, _id: game_id) }

    it "adds the joined player" do
      expect { handle_event }.to change { game.reload.players.count }.
        from(0).
        to(1)
    end
  end

  describe PlayerLeftGameEvent do
    let(:event) do
      build(:player_left_game_event, id: game_id, player_id: contestant.player_id)
    end
    let(:contestant) { build(:contestant) }
    let(:game) { create(:game, _id: game_id, players: [contestant]) }

    it "removes the left player" do
      expect { handle_event }.to change { game.reload.players.count }.
       from(1).
       to(0)
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
    let!(:game) { starting_game }
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
    let!(:game) { starting_game }
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
    let!(:game) { starting_game }
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
    let!(:game) { create(:game, _id: game_id, players: [bob]) }
    let(:bob) { build(:contestant, hand: hand, program: program) }
    let(:hand) { build(:hand) }
    let(:program) { build(:program) }
    let(:event) { build(:game_round_started_event, id: game.id) }

    it "updates the game round number" do
      expect { handle_event }.to change { game.reload.round_number }.to(1)
    end

    context "given a previous round" do
      let(:hand) { build(:hand, :with_cards) }
      let(:program) { build(:program, :with_cards) }

      it "clears all hands" do
        expect { handle_event }.to change { hand.reload.instruction_cards }.
          from(hand.instruction_cards).
          to([])
      end

      it "clears all programs" do
        expect { handle_event }.to change { program.reload.instruction_cards }.
          from(program.instruction_cards).
          to([])
      end
    end
  end

  describe InstructionCardDealtEvent do
    let!(:game) { create(:game, _id: game_id, players: [bob]) }
    let(:bob) { build(:contestant, hand: hand) }
    let(:hand) { build(:hand) }
    let(:event) { build(:instruction_card_dealt_event, id: game.id) }

    it "adds the instruction card to the player's hand" do
      expect { handle_event }.to change { hand.reload.instruction_cards.count }.
        from(0).to(1)
    end

    context "added instruction card" do
      before { handle_event }
      subject { hand.reload.instruction_cards.last }

      its(:action) { is_expected.to eq(InstructionCard::ROTATE) }
      its(:amount) { is_expected.to eq(InstructionCard::U_TURN) }
      its(:priority) { is_expected.to eq(10) }
    end
  end

  describe RobotProgrammedEvent do
    let!(:game) { create(:game, _id: game_id, players: [bob]) }
    let(:bob) { build(:contestant, hand: hand, program: program) }
    let(:hand) { build(:hand, :with_cards) }
    let(:program) { build(:program) }
    let(:event) { build(:robot_programmed_event, id: game._id) }

    it "adds the instruction cards to the player's program" do
      expect { handle_event }.to change { program.reload.instruction_cards.count }.
        from(0).
        to(1)
    end

    it "removes the instruction cards from the player's hand" do
      expect { handle_event }.to change { hand.reload.instruction_cards.count }.
        from(2).
        to(1)
    end
  end

  context "given a board with a robot" do
    let(:game) { create(:game, _id: game_id, board: board) }
    let(:board) { build(:board, robots: [robot]) }
    subject { robot.reload }

    [RobotMovedEvent, RobotPushedEvent].each do |event_class|
      describe event_class do
        before { handle_event }
        let(:event) do
          build(event_class.to_s.underscore, id: game._id, robot: GameUnit.new(
            new_x, new_y, GameUnit::DOWN
          ))
        end

        context "x-movement" do
          let(:robot) { build(:robot, x: 0, y: 0) }
          let(:new_x) { 1 }
          let(:new_y) { 0 }

          its(:x) { is_expected.to eq(1) }
          its(:y) { is_expected.to eq(0) }
        end

        context "y-movement" do
          let(:robot) { build(:robot, x: 0, y: 0) }
          let(:new_x) { 0 }
          let(:new_y) { 1 }

          its(:x) { is_expected.to eq(0) }
          its(:y) { is_expected.to eq(1) }
        end
      end
    end

    describe RobotRotatedEvent do
      before { handle_event }
      let(:event) do
        build(:robot_rotated_event, id: game._id, robot: GameUnit.new(
          0, 0, GameUnit::LEFT
        ))
      end
      let(:robot) { build(:robot, facing: GameUnit::DOWN) }

      its(:facing) { is_expected.to eq(GameUnit::LEFT) }
    end

    describe RobotDiedEvent do
      let(:robot) { build(:robot, x: 0, y: 0) }
      let(:event) { build(:robot_died_event, id: game._id) }

      specify do
        expect { handle_event }.to change { game.reload.board.robots }.to([])
      end
    end
  end
end
