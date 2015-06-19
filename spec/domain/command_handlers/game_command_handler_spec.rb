require "domain_helper"

describe GameCommandHandler, type: :command_handlers do
  let(:id) { "game_id" }
  let(:bob) { "bob" }
  let(:steven) { "steven" }
  let(:deck) { InstructionDeckComposer.compose }
  let(:board) { BoardComposer.compose }

  before { allow_any_instance_of(Array).to receive(:shuffle!) }

  describe CreateGameCommand do
    it "creates a new game" do
      when_command(CreateGameCommand.new(id: id, player_id: bob))
      then_events(
        GameWasCreated.new(id, GameState::LOBBYING, bob),
        PlayerJoinedGame.new(id, bob)
      )
    end
  end

  describe StartGameCommand do
    before do
      given_events(
        GameWasCreated.new(id, GameState::LOBBYING, bob),
        PlayerJoinedGame.new(id, bob)
      )
    end

    it "starts a game" do
      when_command(StartGameCommand.new(id: id, player_id: bob))
      then_events(
        GameStarted.new(id, GameState::RUNNING, deck, board),
        SpawnPlaced.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
        GoalPlaced.new(id, Goal.new(2, 11, 1)),
        GoalPlaced.new(id, Goal.new(10, 7, 2)),
        RobotSpawned.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
        GameRoundStarted.new(id, GameRound.new(1), { "bob" => [] }, "bob" => []),
        InstructionCardDealt.new(id, bob, InstructionCard.u_turn(10)),
        InstructionCardDealt.new(id, bob, InstructionCard.u_turn(20)),
        InstructionCardDealt.new(id, bob, InstructionCard.u_turn(30)),
        InstructionCardDealt.new(id, bob, InstructionCard.u_turn(40)),
        InstructionCardDealt.new(id, bob, InstructionCard.u_turn(50)),
        InstructionCardDealt.new(id, bob, InstructionCard.u_turn(60)),
        InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(70)),
        InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(90)),
        InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(110))
      )
    end

    context "given the game was started by another player" do
      it "denies starting the game" do
        expect { dispatch(StartGameCommand.new(id: id, player_id: steven)) }.
          to raise_error(PlayerNotGameHostError)
      end
    end

    context "given the game has already started" do
      before { given_events(GameStarted.new(id, GameState::RUNNING, deck, board)) }

      it "denies starting the game again" do
        expect { dispatch(StartGameCommand.new(id: id, player_id: bob)) }.
          to raise_error(GameAlreadyStartedError)
      end
    end
  end

  describe ProgramRobotCommand do
    subject(:command) do
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

    it { is_expected.to validate_length_of(:instruction_cards).is_equal_to(5) }

    context "given a started game" do
      before do
        given_events(
          GameWasCreated.new(id, GameState::LOBBYING, bob),
          PlayerJoinedGame.new(id, bob),
          GameStarted.new(id, GameState::RUNNING, deck, board),
          SpawnPlaced.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          GoalPlaced.new(id, Goal.new(2, 11, 1)),
          GoalPlaced.new(id, Goal.new(10, 7, 2)),
          RobotSpawned.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          GameRoundStarted.new(id, GameRound.new(1), { "bob" => [] }, "bob" => []),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(10)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(20)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(30)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(40)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(50)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(60)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(70)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(90)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(110))
        )
      end

      it "programs the players robot" do
        when_command(command)
        then_events(
          RobotProgrammed.new(id, bob, [
            InstructionCard.u_turn(10),
            InstructionCard.u_turn(20),
            InstructionCard.u_turn(30),
            InstructionCard.u_turn(40),
            InstructionCard.u_turn(50)
          ]),
          AllRobotsProgrammed.new(id)
        )
      end

      context "given an instruction card that is not dealt to the player" do
        before { command.instruction_cards[0] = InstructionCard.move_3(790) }

        it "denies programming the robot" do
          expect { dispatch(command) }.to raise_error(IllegalInstructionCardError)
        end
      end

      context "given the robot is already programmed" do
        before do
          given_events(
            RobotProgrammed.new(id, bob, [
              InstructionCard.u_turn(10),
              InstructionCard.u_turn(20),
              InstructionCard.u_turn(30),
              InstructionCard.u_turn(40),
              InstructionCard.u_turn(50)
            ]),
          )
        end

        it "denies re-programming the robot" do
          expect { dispatch(command) }.to raise_error(RobotAlreadyProgrammedError)
        end
      end

      context "given the player has not joined the game" do
        before { command.player_id = steven }

        it "denies programming the robot" do
          expect { dispatch(command) }.to raise_error(PlayerNotInGameError)
        end
      end
    end

    context "given an unstarted game" do
      before do
        given_events(
          GameWasCreated.new(id, GameState::LOBBYING, bob),
          PlayerJoinedGame.new(id, bob),
        )
      end

      it "denies programming the robot" do
        expect { dispatch(command) }.to raise_error(GameNotRunningError)
      end
    end
  end

  describe PlayCurrentRoundCommand do
    context "given all robots where programmed" do
      before do
        given_events(
          GameWasCreated.new(id, GameState::LOBBYING, bob),
          PlayerJoinedGame.new(id, bob),
          GameStarted.new(id, GameState::RUNNING, deck, board),
          SpawnPlaced.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          GoalPlaced.new(id, Goal.new(2, 11, 1)),
          GoalPlaced.new(id, Goal.new(10, 7, 2)),
          RobotSpawned.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          GameRoundStarted.new(id, GameRound.new(1), { "bob" => [] }, "bob" => []),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(10)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(20)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(30)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(40)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(50)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(60)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(70)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(90)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(110)),
          RobotProgrammed.new(id, bob, [
            InstructionCard.u_turn(10),
            InstructionCard.u_turn(20),
            InstructionCard.u_turn(30),
            InstructionCard.u_turn(40),
            InstructionCard.u_turn(50)
          ]),
          AllRobotsProgrammed.new(id)
        )
      end

      it "plays the current round" do
        when_command PlayCurrentRoundCommand.new(id: id)
        then_events(
          GameRoundStartedPlaying.new(id, GameRound.new(1)),
          InstructionCardRevealed.new(id, bob, InstructionCard.u_turn(10)),
          RobotRotated.new(id, bob, GameUnit.new(2, 1, GameUnit::UP)),
          InstructionCardRevealed.new(id, bob, InstructionCard.u_turn(20)),
          RobotRotated.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          InstructionCardRevealed.new(id, bob, InstructionCard.u_turn(30)),
          RobotRotated.new(id, bob, GameUnit.new(2, 1, GameUnit::UP)),
          InstructionCardRevealed.new(id, bob, InstructionCard.u_turn(40)),
          RobotRotated.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          InstructionCardRevealed.new(id, bob, InstructionCard.u_turn(50)),
          RobotRotated.new(id, bob, GameUnit.new(2, 1, GameUnit::UP)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(10)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(20)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(30)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(40)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(50)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(60)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(70)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(90)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(110)),
          GameRoundFinishedPlaying.new(id, GameRound.new(1)),
          GameRoundStarted.new(id, GameRound.new(2), { "bob" => [] }, "bob" => []),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(130)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(150)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(170)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(190)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(210)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(230)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(250)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(270)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(290))
        )
      end
    end

    context "given two players" do
      before do
        given_events(
          GameWasCreated.new(id, GameState::LOBBYING, bob),
          PlayerJoinedGame.new(id, bob),
          PlayerJoinedGame.new(id, steven),
          GameStarted.new(id, GameState::RUNNING, deck, board),
          SpawnPlaced.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          SpawnPlaced.new(id, steven, GameUnit.new(3, 1, GameUnit::DOWN)),
          GoalPlaced.new(id, Goal.new(2, 11, 1)),
          RobotSpawned.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          RobotSpawned.new(id, steven, GameUnit.new(3, 1, GameUnit::DOWN)),
          GameRoundStarted.new(id, GameRound.new(1), { "bob" => [], "steven" => [] }, "bob" => [], "steven" => []),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(10)),
          InstructionCardDealt.new(id, steven, InstructionCard.u_turn(20)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(30)),
          InstructionCardDealt.new(id, steven, InstructionCard.u_turn(40)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(50)),
          InstructionCardDealt.new(id, steven, InstructionCard.u_turn(60)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(70)),
          InstructionCardDealt.new(id, steven, InstructionCard.rotate_left(90)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(110)),
          InstructionCardDealt.new(id, steven, InstructionCard.rotate_left(130)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(150)),
          InstructionCardDealt.new(id, steven, InstructionCard.rotate_left(170)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(190)),
          InstructionCardDealt.new(id, steven, InstructionCard.rotate_left(210)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(230)),
          InstructionCardDealt.new(id, steven, InstructionCard.rotate_left(250)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(270)),
          InstructionCardDealt.new(id, steven, InstructionCard.rotate_left(290)),
          RobotProgrammed.new(id, bob, [
            InstructionCard.u_turn(10),
            InstructionCard.u_turn(30),
            InstructionCard.u_turn(50),
            InstructionCard.rotate_left(70),
            InstructionCard.rotate_left(110)
          ]),
          RobotProgrammed.new(id, steven, [
            InstructionCard.u_turn(20),
            InstructionCard.u_turn(40),
            InstructionCard.u_turn(60),
            InstructionCard.rotate_left(90),
            InstructionCard.rotate_left(130)
          ]),
          AllRobotsProgrammed.new(id)
        )
      end

      it "plays the round" do
        when_command PlayCurrentRoundCommand.new(id: id)
        then_events(
          GameRoundStartedPlaying.new(id, GameRound.new(1)),
          InstructionCardRevealed.new(id, bob, InstructionCard.u_turn(10)),
          InstructionCardRevealed.new(id, steven, InstructionCard.u_turn(20)),
          RobotRotated.new(id, bob, GameUnit.new(2, 1, GameUnit::UP)),
          RobotRotated.new(id, steven, GameUnit.new(3, 1, GameUnit::UP)),
          InstructionCardRevealed.new(id, bob, InstructionCard.u_turn(30)),
          InstructionCardRevealed.new(id, steven, InstructionCard.u_turn(40)),
          RobotRotated.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          RobotRotated.new(id, steven, GameUnit.new(3, 1, GameUnit::DOWN)),
          InstructionCardRevealed.new(id, bob, InstructionCard.u_turn(50)),
          InstructionCardRevealed.new(id, steven, InstructionCard.u_turn(60)),
          RobotRotated.new(id, bob, GameUnit.new(2, 1, GameUnit::UP)),
          RobotRotated.new(id, steven, GameUnit.new(3, 1, GameUnit::UP)),
          InstructionCardRevealed.new(id, bob, InstructionCard.rotate_left(70)),
          InstructionCardRevealed.new(id, steven, InstructionCard.rotate_left(90)),
          RobotRotated.new(id, bob, GameUnit.new(2, 1, GameUnit::LEFT)),
          RobotRotated.new(id, steven, GameUnit.new(3, 1, GameUnit::LEFT)),
          InstructionCardRevealed.new(id, bob, InstructionCard.rotate_left(110)),
          InstructionCardRevealed.new(id, steven, InstructionCard.rotate_left(130)),
          RobotRotated.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          RobotRotated.new(id, steven, GameUnit.new(3, 1, GameUnit::DOWN)),
          GameRoundFinishedPlaying.new(id, GameRound.new(1)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(10)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(20)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(30)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(40)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(50)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(60)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(70)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(90)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(110)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(130)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(150)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(170)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(190)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(210)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(230)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(250)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(270)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(290)),
          GameRoundStarted.new(id, GameRound.new(2), { "bob" => [], "steven" => [] }, "bob" => [], "steven" => []),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(310)),
          InstructionCardDealt.new(id, steven, InstructionCard.rotate_left(330)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(350)),
          InstructionCardDealt.new(id, steven, InstructionCard.rotate_left(370)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(390)),
          InstructionCardDealt.new(id, steven, InstructionCard.rotate_left(410)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_right(80)),
          InstructionCardDealt.new(id, steven, InstructionCard.rotate_right(100)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_right(120)),
          InstructionCardDealt.new(id, steven, InstructionCard.rotate_right(140)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_right(160)),
          InstructionCardDealt.new(id, steven, InstructionCard.rotate_right(180)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_right(200)),
          InstructionCardDealt.new(id, steven, InstructionCard.rotate_right(220)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_right(240)),
          InstructionCardDealt.new(id, steven, InstructionCard.rotate_right(260)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_right(280)),
          InstructionCardDealt.new(id, steven, InstructionCard.rotate_right(300)),
        )
      end
    end

    context "given a winning scenario" do
      before do
        given_events(
          GameWasCreated.new(id, GameState::LOBBYING, bob),
          PlayerJoinedGame.new(id, bob),
          GameStarted.new(id, GameState::RUNNING, deck, board),
          SpawnPlaced.new(id, bob, GameUnit.new(0, 0, GameUnit::DOWN)),
          GoalPlaced.new(id, Goal.new(0, 0, 1)),
          RobotSpawned.new(id, bob, GameUnit.new(0, 0, GameUnit::DOWN)),
          GameRoundStarted.new(id, GameRound.new(1), { "bob" => [] }, "bob" => []),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(10)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(20)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(30)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(40)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(50)),
          InstructionCardDealt.new(id, bob, InstructionCard.u_turn(60)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(70)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(90)),
          InstructionCardDealt.new(id, bob, InstructionCard.rotate_left(110)),
          RobotProgrammed.new(id, bob, [
            InstructionCard.u_turn(10),
            InstructionCard.u_turn(20),
            InstructionCard.u_turn(30),
            InstructionCard.u_turn(40),
            InstructionCard.u_turn(50)
          ]),
          AllRobotsProgrammed.new(id)
        )
      end

      it "wins the game for a player" do
        when_command PlayCurrentRoundCommand.new(id: id)
        then_events(
          GameRoundStartedPlaying.new(id, GameRound.new(1)),
          InstructionCardRevealed.new(id, bob, InstructionCard.u_turn(10)),
          RobotRotated.new(id, bob, GameUnit.new(0, 0, GameUnit::UP)),
          InstructionCardRevealed.new(id, bob, InstructionCard.u_turn(20)),
          RobotRotated.new(id, bob, GameUnit.new(0, 0, GameUnit::DOWN)),
          InstructionCardRevealed.new(id, bob, InstructionCard.u_turn(30)),
          RobotRotated.new(id, bob, GameUnit.new(0, 0, GameUnit::UP)),
          InstructionCardRevealed.new(id, bob, InstructionCard.u_turn(40)),
          RobotRotated.new(id, bob, GameUnit.new(0, 0, GameUnit::DOWN)),
          InstructionCardRevealed.new(id, bob, InstructionCard.u_turn(50)),
          RobotRotated.new(id, bob, GameUnit.new(0, 0, GameUnit::UP)),
          GoalTouched.new(id, bob, Goal.new(0, 0, 1)),
          PlayerWonGame.new(id, bob),
          SpawnReplaced.new(id, bob, GameUnit.new(0, 0, GameUnit::UP)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(10)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(20)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(30)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(40)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(50)),
          InstructionCardDiscarded.new(id, InstructionCard.u_turn(60)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(70)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(90)),
          InstructionCardDiscarded.new(id, InstructionCard.rotate_left(110)),
          GameRoundFinishedPlaying.new(id, GameRound.new(1)),
          GameEnded.new(id, GameState::ENDED)
        )
      end
    end
  end

  describe JoinGameCommand do
    subject(:command) { JoinGameCommand.new(id: id, player_id: steven) }
    before { given_events GameWasCreated.new(id, GameState::LOBBYING, bob) }

    it "joins a game" do
      when_command(command)
      then_events(PlayerJoinedGame.new(id, steven))
    end

    context "given the player already joined the game" do
      before { given_events PlayerJoinedGame.new(id, steven) }

      it "denies joining the game again" do
        expect { dispatch(command) }.to raise_error(PlayerAlreadyInGameError)
      end
    end

    context "given the game already started" do
      before { given_events GameStarted.new(id, GameState::RUNNING, deck, board) }

      it "denies joining the game" do
        expect { dispatch(command) }.to raise_error(GameAlreadyStartedError)
      end
    end
  end

  describe LeaveGameCommand do
    subject(:command) { LeaveGameCommand.new(id: id, player_id: steven) }
    before { given_events GameWasCreated.new(id, GameState::LOBBYING, bob) }

    context "given the player joined the game" do
      before { given_events PlayerJoinedGame.new(id, steven) }

      it "leaves a game" do
        when_command(command)
        then_events(PlayerLeftGame.new(id, steven))
      end

      context "and the game already started" do
        before { given_events GameStarted.new(id, GameState::RUNNING, deck, board) }

        it "denies leaving the game" do
          expect { dispatch(command) }.to raise_error(GameAlreadyStartedError)
        end
      end
    end

    context "given the player has not joined the game" do
      it "denies leaving the game" do
        expect { dispatch(command) }.to raise_error(PlayerNotInGameError)
      end
    end
  end
end
