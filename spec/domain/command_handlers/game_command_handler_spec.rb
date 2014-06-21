require 'domain_helper'

describe GameCommandHandler, type: :command_handlers do
  let(:id) { "game_id" }
  let(:bob) { "bob" }
  let(:steven) { "steven" }

  let(:create_game_command) { CreateGameCommand.new(id: id, player_id: bob) }
  let(:start_game_command) { StartGameCommand.new(id: id, player_id: bob) }
  let(:program_robot_command) do
    ProgramRobotCommand.new(
      id: id,
      player_id: bob,
      instruction_cards: [
        InstructionCard.u_turn(10),
        InstructionCard.u_turn(20),
        InstructionCard.u_turn(30),
        InstructionCard.u_turn(40),
        InstructionCard.u_turn(50)
      ]
    )
  end
  let(:join_game_command) { JoinGameCommand.new(id: id, player_id: steven) }
  let(:leave_game_command) { LeaveGameCommand.new(id: id, player_id: steven) }

  context "given a single player" do
    describe CreateGameCommand do
      let(:command) { create_game_command }

      it_behaves_like "an event publisher" do
        let(:expected_events) do
          [
            GameCreatedEvent.new(id, GameState::LOBBYING, bob),
            PlayerJoinedGameEvent.new(id, bob)
          ]
        end
      end
    end

    describe StartGameCommand do
      let(:command) { start_game_command }
      before { dispatch(create_game_command) }

      it_behaves_like "an event publisher" do
        before do
          allow(Time).to receive(:current) { Time.parse("2014-06-14T23:00:00") }
          allow_any_instance_of(Array).to receive(:shuffle!)
        end

        let(:instruction_deck) { InstructionDeck.compose }
        let(:board) { Board.compose }
        let(:expected_events) do
          [
            GameStartedEvent.new(
              id,
              GameState::RUNNING,
              instruction_deck,
              board
            ),
            SpawnPlacedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
            GoalPlacedEvent.new(id, Goal.new(2, 11, 1)),
            GoalPlacedEvent.new(id, Goal.new(10, 7, 2)),
            RobotSpawnedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
            GameRoundStartedEvent.new(id, GameRound.new(
              1,
              Time.current,
              1.minute.from_now
            )),
            InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(10)),
            InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(20)),
            InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(30)),
            InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(40)),
            InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(50)),
            InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(60)),
            InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(70)),
            InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(90)),
            InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(110))
          ]
        end
      end

      context "when dispatched by non-host" do
        before { command.player_id = steven }

        specify do
          expect { dispatch(command) }.to raise_error(PlayerNotGameHostError)
        end
      end

      context "when already started" do
        before { dispatch(command) }

        specify do
          expect { dispatch(command) }.to raise_error(GameAlreadyStartedError)
        end
      end

      context "when game finished" do
        pending
      end
    end

    describe ProgramRobotCommand do
      let(:command) { program_robot_command }

      describe "validations" do
        it { is_expected.to ensure_length_of(:instruction_cards).is_equal_to(5) }
      end

      it_behaves_like "an event publisher" do
        before do
          dispatch(create_game_command)
          dispatch(start_game_command)
        end

        let(:expected_events) do
          [
            RobotProgrammedEvent.new(id, bob, [
              InstructionCard.u_turn(10),
              InstructionCard.u_turn(20),
              InstructionCard.u_turn(30),
              InstructionCard.u_turn(40),
              InstructionCard.u_turn(50)
            ]),
            AllRobotsProgrammedEvent.new(id),
            RobotRotatedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::UP)),
            RobotRotatedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
            RobotRotatedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::UP)),
            RobotRotatedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
            RobotRotatedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::UP))
          ]
        end
      end

      context "when trying to program an instruction that is not dealt to player" do
        before do
          dispatch(create_game_command)
          dispatch(start_game_command)

          command.instruction_cards[0] = InstructionCard.move_3(790)
        end

        specify do
          expect { dispatch(command) }.to raise_error(IllegalInstructionCardError)
        end
      end

      context "when robot is already programmed" do
        before do
          dispatch(create_game_command)
          dispatch(start_game_command)
          dispatch(program_robot_command)
        end

        specify do
          expect { dispatch(command) }.to raise_error(RobotAlreadyProgrammedError)
        end
      end

      context "when game not yet started" do
        before { dispatch(create_game_command) }

        specify do
          expect { dispatch(command) }.to raise_error(GameNotRunningError)
        end
      end

      context "when player not in game" do
        before do
          dispatch(create_game_command)
          dispatch(start_game_command)

          command.player_id = steven
        end

        specify do
          expect { dispatch(command) }.to raise_error(PlayerNotInGameError)
        end
      end

      context "when game finished" do
        pending
      end
    end
  end

  describe JoinGameCommand do
    let(:command) { join_game_command }

    it_behaves_like "an event publisher" do
      before { dispatch(create_game_command) }

      let(:expected_events) { [PlayerJoinedGameEvent.new(id, steven)] }
    end

    context "when already in game" do
      before do
        dispatch(create_game_command)
        dispatch(join_game_command)
      end

      specify do
        expect { dispatch(command) }.to raise_error(PlayerAlreadyInGameError)
      end
    end

    context "when game already started" do
      before do
        dispatch(create_game_command)
        dispatch(start_game_command)
      end

      specify do
        expect { dispatch(command) }.to raise_error(GameAlreadyStartedError)
      end
    end

    context "when game finished" do
      pending
    end

    context "when game is full" do
      pending
    end
  end

  describe LeaveGameCommand do
    let(:command) { leave_game_command }

    it_behaves_like "an event publisher" do
      before do
        dispatch(create_game_command)
        dispatch(join_game_command)
      end

      let(:expected_events) { [PlayerLeftGameEvent.new(id, steven)] }
    end

    context "when not in game" do
      before do
        dispatch(create_game_command)
      end

      specify do
        expect { dispatch(command) }.to raise_error(PlayerNotInGameError)
      end
    end

    context "when game already started" do
      before do
        dispatch(create_game_command)
        dispatch(join_game_command)
        dispatch(start_game_command)
      end

      specify do
        expect { dispatch(command) }.to raise_error(GameAlreadyStartedError)
      end
    end

    context "when game finished" do
      pending
    end
  end

  describe MoveRobotCommand do
    let(:command) { MoveRobotCommand.new(id: id, speed: 1) }

    describe "validations" do
      it do
        should ensure_inclusion_of(:speed).in_array(MoveRobotCommand::SPEEDS)
      end
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

