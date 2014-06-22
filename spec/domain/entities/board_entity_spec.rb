require 'domain_helper'

describe BoardEntity, type: :entities do
  let(:tiles) { Board.compose(2, 2) }
  let(:board) { BoardEntity.new(tiles) }
  let(:entity) { board }

  let(:bob) { "bob" }
  let(:steven) { "steven" }

  let(:spawn_bob) { GameUnit.new(0, 1, GameUnit::RIGHT) }
  let(:robot_bob) { GameUnit.new(0, 1, GameUnit::RIGHT) }

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
    let(:tiles) { Board.compose(3, 5) }
    subject { board.instruct_robot(robot, instruction) }

    context "given a spawned robot" do
      let(:robot) { steven }

      before do
        given_events(
          SpawnPlacedEvent.new(id, steven, spawn_steven),
          RobotSpawnedEvent.new(id, steven, robot_steven)
        )
      end

      context "when instructing 'move 1'" do
        let(:instruction) { InstructionCard.move_1(0) }

        specify do
          expect_events(
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 2, GameUnit::DOWN))
          )
        end
      end

      context "when instructing 'move 2'" do
        let(:instruction) { InstructionCard.move_2(0) }

        specify do
          expect_events(
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 2, GameUnit::DOWN)),
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 3, GameUnit::DOWN))
          )
        end
      end

      context "when instructing 'move 2'" do
        let(:instruction) { InstructionCard.move_3(0) }

        specify do
          expect_events(
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 2, GameUnit::DOWN)),
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 3, GameUnit::DOWN)),
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 4, GameUnit::DOWN))
          )
        end
      end

      context "when instructing 'back-up'" do
        let(:instruction) { InstructionCard.back_up(0) }

        specify do
          expect_events(
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 0, GameUnit::DOWN))
          )
        end
      end

      context "when instructing 'rotate right'" do
        let(:instruction) { InstructionCard.rotate_right(0) }

        specify do
          expect_events(
            RobotRotatedEvent.new(id, steven, GameUnit.new(1, 1, GameUnit::LEFT))
          )
        end
      end

      context "when instructing 'rotate left'" do
        let(:instruction) { InstructionCard.rotate_left(0) }

        specify do
          expect_events(
            RobotRotatedEvent.new(id, steven, GameUnit.new(1, 1, GameUnit::RIGHT))
          )
        end
      end

      context "when instructing 'u-turn'" do
        let(:instruction) { InstructionCard.u_turn(0) }

        specify do
          expect_events(
            RobotRotatedEvent.new(id, steven, GameUnit.new(1, 1, GameUnit::UP))
          )
        end
      end

      context "given a robot near the edge of the board" do
        let(:instruction) { InstructionCard.move_3(0) }

        before do
          given_events(
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 4, GameUnit::DOWN))
          )
        end

        it "moves and dies" do
          expect_events(
            RobotMovedEvent.new(id, steven, GameUnit.new(1, 5, GameUnit::DOWN)),
            RobotDiedEvent.new(id, steven, GameUnit.new(1, 5, GameUnit::DOWN))
          )
        end
      end
    end

    context "given two spawned robots" do
      let(:robot) { bob }

      before do
        given_events(
          SpawnPlacedEvent.new(id, steven, spawn_steven),
          SpawnPlacedEvent.new(id, bob, spawn_bob),
          RobotSpawnedEvent.new(id, steven, robot_steven),
          RobotSpawnedEvent.new(id, bob, robot_bob)
        )
      end

      context "given a robot standing in front of another robot" do
        let(:instruction) { InstructionCard.move_1(0) }

        it "is pushed" do
          expect_events(
            RobotPushedEvent.new(id, steven, GameUnit.new(2, 1, GameUnit::DOWN)),
            RobotMovedEvent.new(id, bob, GameUnit.new(1, 1, GameUnit::RIGHT))
          )
        end

        context "and near the edge of the board" do
          let(:instruction) { InstructionCard.move_2(0) }

          it "is pushed and dies" do
            expect_events(
              RobotPushedEvent.new(id, steven, GameUnit.new(2, 1, GameUnit::DOWN)),
              RobotMovedEvent.new(id, bob, GameUnit.new(1, 1, GameUnit::RIGHT)),
              RobotPushedEvent.new(id, steven, GameUnit.new(3, 1, GameUnit::DOWN)),
              RobotDiedEvent.new(id, steven, GameUnit.new(3, 1, GameUnit::DOWN)),
              RobotMovedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::RIGHT))
            )
          end
        end
      end

      context "and a third spawned robot" do
        let(:peter) { "peter" }
        let(:spawn_peter) { GameUnit.new(2, 1, GameUnit::UP) }
        let(:robot_peter) { GameUnit.new(2, 1, GameUnit::UP) }

        before do
          given_events(
            SpawnPlacedEvent.new(id, peter, spawn_peter),
            RobotSpawnedEvent.new(id, peter, robot_peter)
          )
        end

        context "train wreck" do
          let(:instruction) { InstructionCard.move_3(0) }

          specify do
            expect_events(
              RobotPushedEvent.new(id, peter, GameUnit.new(3, 1, GameUnit::UP)),
              RobotDiedEvent.new(id, peter, GameUnit.new(3, 1, GameUnit::UP)),
              RobotPushedEvent.new(id, steven, GameUnit.new(2, 1, GameUnit::DOWN)),
              RobotMovedEvent.new(id, bob, GameUnit.new(1, 1, GameUnit::RIGHT)),
              RobotPushedEvent.new(id, steven, GameUnit.new(3, 1, GameUnit::DOWN)),
              RobotDiedEvent.new(id, steven, GameUnit.new(3, 1, GameUnit::DOWN)),
              RobotMovedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::RIGHT)),
              RobotMovedEvent.new(id, bob, GameUnit.new(3, 1, GameUnit::RIGHT)),
              RobotDiedEvent.new(id, bob, GameUnit.new(3, 1, GameUnit::RIGHT))
            )
          end
        end
      end
    end

    context "when not spawned" do
      pending
    end
  end
end
