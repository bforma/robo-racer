require 'domain_helper'

describe BoardEntity, type: :entities do
  let(:tiles) { Board.compose(2, 2) }
  let(:board) { BoardEntity.new(tiles) }
  let(:entity) { board }

  let(:bob) { "bob" }
  let(:steven) { "steven" }

  let(:spawn_bob) { GameUnit.new(0, 0, GameUnit::RIGHT) }
  let(:robot_bob) { GameUnit.new(0, 0, GameUnit::RIGHT) }

  let(:spawn_steven) { GameUnit.new(1, 1, GameUnit::DOWN) }
  let(:robot_steven) { GameUnit.new(1, 1, GameUnit::DOWN) }

  describe "#place_spawn" do
    subject { board.place_spawn(spawn_bob, bob) }

    it "places a spawn point" do
      expect_events(SpawnPlacedEvent.new(id, bob, spawn_bob))
    end

    context "when placed outside the board" do
      let(:spawn_bob) { GameUnit.new(-1, -1, GameUnit::DOWN) }

      specify { expect { subject }.to raise_error(IllegalLocationError) }
    end

    context "when placed on a goal" do
      pending
    end

    context "when a spawn is already placed for a player" do
      before { given_events(SpawnPlacedEvent.new(id, bob, spawn_bob)) }

      specify { expect { subject }.to raise_error(SpawnAlreadyPlacedError) }
    end
  end

  describe "#place_goal" do
    let(:goal) { Goal.new(0, 0, 1) }
    subject { board.place_goal(goal) }

    it "places a goal" do
      expect_events(GoalPlacedEvent.new(id, goal))
    end

    context "when placed outside the board" do
      let(:goal) { Goal.new(-1, -1, 1) }

      specify { expect { subject }.to raise_error(IllegalLocationError) }
    end

    context "when placed on a spawn" do
      pending
    end

    context "when a goal is already placed" do
      before { given_events(GoalPlacedEvent.new(id, goal)) }

      specify { expect { subject }.to raise_error(GoalAlreadyPlacedError) }
    end
  end

  describe "#spawn_players" do
    subject { board.spawn_players }

    context "given a spawn" do
      before { given_events(SpawnPlacedEvent.new(id, bob, spawn_bob)) }

      specify { expect_events(RobotSpawnedEvent.new(id, bob, robot_bob)) }
    end

    context "given multiple spawns" do
      before do
        given_events(
          SpawnPlacedEvent.new(id, bob, spawn_bob),
          SpawnPlacedEvent.new(id, steven, spawn_steven)
        )
      end

      specify do
        expect_events(
          RobotSpawnedEvent.new(id, bob, robot_bob),
          RobotSpawnedEvent.new(id, steven, robot_steven)
        )
      end
    end

    context "given no spawns" do
      pending
    end
  end

  describe "#instruct_robot" do
    let(:tiles) { Board.compose(5, 5) }
    subject { board.instruct_robot(steven, instruction) }

    context "given a spawned robot" do
      before do
        given_events(
          SpawnPlacedEvent.new(id, steven, spawn_steven),
          RobotSpawnedEvent.new(id, steven, robot_steven)
        )
      end

      context "given a 'move 1' instruction" do
        let(:instruction) { InstructionCard.move_1(0) }

        specify do
          expect_events(
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 2, GameUnit::DOWN))
          )
        end
      end

      context "given a 'move 2' instruction" do
        let(:instruction) { InstructionCard.move_2(0) }

        specify do
          expect_events(
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 2, GameUnit::DOWN)),
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 3, GameUnit::DOWN))
          )
        end
      end

      context "given a 'move 3' instruction" do
        let(:instruction) { InstructionCard.move_3(0) }

        specify do
          expect_events(
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 2, GameUnit::DOWN)),
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 3, GameUnit::DOWN)),
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 4, GameUnit::DOWN))
          )
        end
      end

      context "given a 'back-up' instruction" do
        let(:instruction) { InstructionCard.back_up(0) }

        specify do
          expect_events(
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 0, GameUnit::DOWN))
          )
        end
      end

      context "given a 'rotate right' instruction" do
        let(:instruction) { InstructionCard.rotate_right(0) }

        specify do
          expect_events(
            RobotRotatedEvent.new(id, steven, GameUnit.new(1, 1, GameUnit::LEFT))
          )
        end
      end

      context "given a 'rotate left' instruction" do
        let(:instruction) { InstructionCard.rotate_left(0) }

        specify do
          expect_events(
            RobotRotatedEvent.new(id, steven, GameUnit.new(1, 1, GameUnit::RIGHT))
          )
        end
      end

      context "given a 'u-turn' instruction" do
        let(:instruction) { InstructionCard.u_turn(0) }

        specify do
          expect_events(
            RobotRotatedEvent.new(id, steven, GameUnit.new(1, 1, GameUnit::UP))
          )
        end
      end

      context "given an instruction that moves a robot off the board" do
        let(:instruction) { InstructionCard.move_3(0) }

        before do
          given_events(
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 4, GameUnit::DOWN))
          )
        end

        specify do
          expect_events(
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 5, GameUnit::DOWN)),
            RobotDiedEvent.new(id, steven, GameUnit.new(1, 5, GameUnit::DOWN))
          )
        end
      end
    end

    context "when not spawned" do
      pending
    end
  end
end
