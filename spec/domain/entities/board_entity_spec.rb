require "domain_helper"

describe BoardEntity, type: :entities do
  let(:tiles) { BoardComposer.compose(2, 2) }
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
      expect_events(SpawnPlaced.new(id, bob, spawn_bob))
    end

    context "when placed outside the board" do
      let(:spawn_bob) { GameUnit.new(-1, -1, GameUnit::DOWN) }

      specify { expect { subject }.to raise_error(IllegalLocationError) }
    end

    context "when a spawn is already placed for a player" do
      before { given_events(SpawnPlaced.new(id, bob, spawn_bob)) }

      specify { expect { subject }.to raise_error(SpawnAlreadyPlacedError) }
    end
  end

  describe "#place_goal" do
    let(:goal) { Goal.new(0, 0, 1) }
    subject { board.place_goal(goal) }

    it "places a goal" do
      expect_events(GoalPlaced.new(id, goal))
    end

    context "when placed outside the board" do
      let(:goal) { Goal.new(-1, -1, 1) }

      specify { expect { subject }.to raise_error(IllegalLocationError) }
    end

    context "when a goal is already placed" do
      before { given_events(GoalPlaced.new(id, goal)) }

      specify { expect { subject }.to raise_error(GoalAlreadyPlacedError) }
    end
  end

  describe "#spawn_players" do
    subject { board.spawn_players }

    context "given a spawn" do
      before { given_events(SpawnPlaced.new(id, bob, spawn_bob)) }

      specify { expect_events(RobotSpawned.new(id, bob, robot_bob)) }

      context "and already spawned" do
        before { given_events(RobotSpawned.new(id, bob, robot_bob)) }

        specify { expect_no_events }
      end

      context "and replaced" do
        let(:replaced_spawn) { GameUnit.new(0, 0, GameUnit::UP) }

        before do
          given_events(
            SpawnReplaced.new(id, bob, replaced_spawn)
          )
        end

        specify do
          expect_events(RobotSpawned.new(id, bob, replaced_spawn))
        end
      end
    end

    context "given multiple spawns" do
      before do
        given_events(
          SpawnPlaced.new(id, bob, spawn_bob),
          SpawnPlaced.new(id, steven, spawn_steven)
        )
      end

      specify do
        expect_events(
          RobotSpawned.new(id, bob, robot_bob),
          RobotSpawned.new(id, steven, robot_steven)
        )
      end
    end
  end

  describe "#instruct_robot" do
    let(:tiles) { BoardComposer.compose(3, 5) }
    subject { board.instruct_robot(robot, instruction) }

    context "given a spawned robot" do
      let(:robot) { steven }

      before do
        given_events(
          SpawnPlaced.new(id, steven, spawn_steven),
          RobotSpawned.new(id, steven, robot_steven)
        )
      end

      context "when instructing 'move 1'" do
        let(:instruction) { InstructionCard.move_1(0) }

        specify do
          expect_events(
            RobotMoved.new(id, steven, GameUnit.new(1, 2, GameUnit::DOWN))
          )
        end
      end

      context "when instructing 'move 2'" do
        let(:instruction) { InstructionCard.move_2(0) }

        specify do
          expect_events(
            RobotMoved.new(id, steven, GameUnit.new(1, 2, GameUnit::DOWN)),
            RobotMoved.new(id, steven, GameUnit.new(1, 3, GameUnit::DOWN))
          )
        end
      end

      context "when instructing 'move 2'" do
        let(:instruction) { InstructionCard.move_3(0) }

        specify do
          expect_events(
            RobotMoved.new(id, steven, GameUnit.new(1, 2, GameUnit::DOWN)),
            RobotMoved.new(id, steven, GameUnit.new(1, 3, GameUnit::DOWN)),
            RobotMoved.new(id, steven, GameUnit.new(1, 4, GameUnit::DOWN))
          )
        end
      end

      context "when instructing 'back-up'" do
        let(:instruction) { InstructionCard.back_up(0) }

        specify do
          expect_events(
            RobotMoved.new(id, steven, GameUnit.new(1, 0, GameUnit::DOWN))
          )
        end
      end

      context "when instructing 'rotate right'" do
        let(:instruction) { InstructionCard.rotate_right(0) }

        specify do
          expect_events(
            RobotRotated.new(id, steven, GameUnit.new(1, 1, GameUnit::LEFT))
          )
        end
      end

      context "when instructing 'rotate left'" do
        let(:instruction) { InstructionCard.rotate_left(0) }

        specify do
          expect_events(
            RobotRotated.new(id, steven, GameUnit.new(1, 1, GameUnit::RIGHT))
          )
        end
      end

      context "when instructing 'u-turn'" do
        let(:instruction) { InstructionCard.u_turn(0) }

        specify do
          expect_events(
            RobotRotated.new(id, steven, GameUnit.new(1, 1, GameUnit::UP))
          )
        end
      end

      context "given a robot near the edge of the board" do
        let(:instruction) { InstructionCard.move_3(0) }

        before do
          given_events(
            RobotMoved.new(id, steven, GameUnit.new(1, 4, GameUnit::DOWN))
          )
        end

        it "moves and dies" do
          expect_events(
            RobotMoved.new(id, steven, GameUnit.new(1, 5, GameUnit::DOWN)),
            RobotDied.new(id, steven, GameUnit.new(1, 5, GameUnit::DOWN))
          )
        end

        context "and it moved and died" do
          before do
            given_events(
              RobotMoved.new(id, steven, GameUnit.new(1, 5, GameUnit::DOWN)),
              RobotDied.new(id, steven, GameUnit.new(1, 5, GameUnit::DOWN))
            )
          end

          it "fizzles" do
            expect_no_events
          end
        end
      end
    end

    context "given two spawned robots" do
      let(:robot) { bob }

      before do
        given_events(
          SpawnPlaced.new(id, steven, spawn_steven),
          SpawnPlaced.new(id, bob, spawn_bob),
          RobotSpawned.new(id, steven, robot_steven),
          RobotSpawned.new(id, bob, robot_bob)
        )
      end

      context "given a robot standing in front of another robot" do
        let(:instruction) { InstructionCard.move_1(0) }

        it "is pushed" do
          expect_events(
            RobotPushed.new(id, steven, GameUnit.new(2, 1, GameUnit::DOWN)),
            RobotMoved.new(id, bob, GameUnit.new(1, 1, GameUnit::RIGHT))
          )
        end

        context "and near the edge of the board" do
          let(:instruction) { InstructionCard.move_2(0) }

          it "is pushed and dies" do
            expect_events(
              RobotPushed.new(id, steven, GameUnit.new(2, 1, GameUnit::DOWN)),
              RobotMoved.new(id, bob, GameUnit.new(1, 1, GameUnit::RIGHT)),
              RobotPushed.new(id, steven, GameUnit.new(3, 1, GameUnit::DOWN)),
              RobotDied.new(id, steven, GameUnit.new(3, 1, GameUnit::DOWN)),
              RobotMoved.new(id, bob, GameUnit.new(2, 1, GameUnit::RIGHT))
            )
          end
        end
      end

      context "and a third spawned robot" do
        let(:peter) { "peter" }
        let(:spawn_peter) { GameUnit.new(2, 1, GameUnit::UP) }
        let(:robot_peter) { GameUnit.new(2, 1, GameUnit::UP) }
        let(:instruction) { InstructionCard.move_3(0) }

        before do
          given_events(
            SpawnPlaced.new(id, peter, spawn_peter),
            RobotSpawned.new(id, peter, robot_peter)
          )
        end

        specify "train wreck" do
          expect_events(
            RobotPushed.new(id, peter, GameUnit.new(3, 1, GameUnit::UP)),
            RobotDied.new(id, peter, GameUnit.new(3, 1, GameUnit::UP)),
            RobotPushed.new(id, steven, GameUnit.new(2, 1, GameUnit::DOWN)),
            RobotMoved.new(id, bob, GameUnit.new(1, 1, GameUnit::RIGHT)),
            RobotPushed.new(id, steven, GameUnit.new(3, 1, GameUnit::DOWN)),
            RobotDied.new(id, steven, GameUnit.new(3, 1, GameUnit::DOWN)),
            RobotMoved.new(id, bob, GameUnit.new(2, 1, GameUnit::RIGHT)),
            RobotMoved.new(id, bob, GameUnit.new(3, 1, GameUnit::RIGHT)),
            RobotDied.new(id, bob, GameUnit.new(3, 1, GameUnit::RIGHT))
          )
        end
      end
    end
  end

  describe "#touch_goals" do
    subject { board.touch_goals }
    let(:goal_1) { Goal.new(1, 2, 1) }
    let(:goal_2) { Goal.new(1, 0, 2) }
    let(:goal) { goal_1 }

    before do
      given_events(
        SpawnPlaced.new(id, steven, spawn_steven),
        GoalPlaced.new(id, goal_1),
        GoalPlaced.new(id, goal_2),
        RobotSpawned.new(id, steven, robot_steven)
      )
    end

    context "given no robot on a goal" do
      specify { expect_no_events }
    end

    context "given a robot on goal 1" do
      before do
        given_events(RobotMoved.new(id, steven, robot_steven.move(1)))
      end

      specify do
        expect_events(GoalTouched.new(id, steven, goal_1))
      end

      context "and already touched goal 1" do
        before do
          given_events(GoalTouched.new(id, steven, goal_1))
        end

        specify { expect_no_events }
      end

      context "and already touched goal 2" do
        before do
          given_events(GoalTouched.new(id, steven, goal_2))
        end

        specify { expect_no_events }
      end
    end

    context "given a robot on goal 2" do
      let(:goal) { goal_2 }

      before do
        given_events(RobotMoved.new(id, steven, robot_steven.move(-1)))
      end

      specify { expect_no_events }

      context "and already touched goal 1" do
        before do
          given_events(GoalTouched.new(id, steven, goal_1))
        end

        specify do
          expect_events(
            GoalTouched.new(id, steven, goal_2),
            PlayerWonGame.new(id, steven)
          )
        end
      end
    end
  end

  describe "#replace_spawns" do
    subject { board.replace_spawns }
    let(:goal) { Goal.new(1, 2, 1) }

    before do
      given_events(
        SpawnPlaced.new(id, steven, spawn_steven),
        GoalPlaced.new(id, goal),
        RobotSpawned.new(id, steven, robot_steven)
      )
    end

    context "given no robot on a goal" do
      specify { expect_no_events }
    end

    context "given a robot on a goal" do
      before do
        given_events(RobotMoved.new(id, steven, robot_steven.move(1)))
      end

      specify do
        expect_events(
          SpawnReplaced.new(
            id,
            steven,
            GameUnit.new(goal.x, goal.y, robot_steven.facing)
          )
        )
      end
    end
  end
end
