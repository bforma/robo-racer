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
        GameCreatedEvent.new(id, GameState::LOBBYING, bob),
        PlayerJoinedGameEvent.new(id, bob)
      )
    end
  end

  describe StartGameCommand do
    before do
      given_events(
        GameCreatedEvent.new(id, GameState::LOBBYING, bob),
        PlayerJoinedGameEvent.new(id, bob)
      )
    end

    it "starts a game" do
      when_command(StartGameCommand.new(id: id, player_id: bob))
      then_events(
        GameStartedEvent.new(id, GameState::RUNNING, deck, board),
        SpawnPlacedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
        GoalPlacedEvent.new(id, Goal.new(2, 11, 1)),
        GoalPlacedEvent.new(id, Goal.new(10, 7, 2)),
        RobotSpawnedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
        GameRoundStartedEvent.new(id, GameRound.new(1), { "bob" => [] }, "bob" => []),
        InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(10)),
        InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(20)),
        InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(30)),
        InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(40)),
        InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(50)),
        InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(60)),
        InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(70)),
        InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(90)),
        InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(110))
      )
    end

    context "given the game was started by another player" do
      it "denies starting the game" do
        expect { dispatch(StartGameCommand.new(id: id, player_id: steven)) }.
          to raise_error(PlayerNotGameHostError)
      end
    end

    context "given the game has already started" do
      before { given_events(GameStartedEvent.new(id, GameState::RUNNING, deck, board)) }

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
          GameCreatedEvent.new(id, GameState::LOBBYING, bob),
          PlayerJoinedGameEvent.new(id, bob),
          GameStartedEvent.new(id, GameState::RUNNING, deck, board),
          SpawnPlacedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          GoalPlacedEvent.new(id, Goal.new(2, 11, 1)),
          GoalPlacedEvent.new(id, Goal.new(10, 7, 2)),
          RobotSpawnedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          GameRoundStartedEvent.new(id, GameRound.new(1), { "bob" => [] }, "bob" => []),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(10)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(20)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(30)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(40)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(50)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(60)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(70)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(90)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(110))
        )
      end

      it "programs the players robot" do
        when_command(command)
        then_events(
          RobotProgrammedEvent.new(id, bob, [
            InstructionCard.u_turn(10),
            InstructionCard.u_turn(20),
            InstructionCard.u_turn(30),
            InstructionCard.u_turn(40),
            InstructionCard.u_turn(50)
          ]),
          AllRobotsProgrammedEvent.new(id)
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
            RobotProgrammedEvent.new(id, bob, [
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
          GameCreatedEvent.new(id, GameState::LOBBYING, bob),
          PlayerJoinedGameEvent.new(id, bob),
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
          GameCreatedEvent.new(id, GameState::LOBBYING, bob),
          PlayerJoinedGameEvent.new(id, bob),
          GameStartedEvent.new(id, GameState::RUNNING, deck, board),
          SpawnPlacedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          GoalPlacedEvent.new(id, Goal.new(2, 11, 1)),
          GoalPlacedEvent.new(id, Goal.new(10, 7, 2)),
          RobotSpawnedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          GameRoundStartedEvent.new(id, GameRound.new(1), { "bob" => [] }, "bob" => []),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(10)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(20)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(30)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(40)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(50)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(60)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(70)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(90)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(110)),
          RobotProgrammedEvent.new(id, bob, [
            InstructionCard.u_turn(10),
            InstructionCard.u_turn(20),
            InstructionCard.u_turn(30),
            InstructionCard.u_turn(40),
            InstructionCard.u_turn(50)
          ]),
          AllRobotsProgrammedEvent.new(id)
        )
      end

      it "plays the current round" do
        when_command PlayCurrentRoundCommand.new(id: id)
        then_events(
          GameRoundStartedPlayingEvent.new(id, GameRound.new(1)),
          InstructionCardRevealedEvent.new(id, bob, InstructionCard.u_turn(10)),
          RobotRotatedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::UP)),
          InstructionCardRevealedEvent.new(id, bob, InstructionCard.u_turn(20)),
          RobotRotatedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          InstructionCardRevealedEvent.new(id, bob, InstructionCard.u_turn(30)),
          RobotRotatedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::UP)),
          InstructionCardRevealedEvent.new(id, bob, InstructionCard.u_turn(40)),
          RobotRotatedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          InstructionCardRevealedEvent.new(id, bob, InstructionCard.u_turn(50)),
          RobotRotatedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::UP)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(10)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(20)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(30)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(40)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(50)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(60)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(70)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(90)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(110)),
          GameRoundFinishedPlayingEvent.new(id, GameRound.new(1)),
          GameRoundStartedEvent.new(id, GameRound.new(2), { "bob" => [] }, "bob" => []),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(130)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(150)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(170)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(190)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(210)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(230)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(250)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(270)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(290))
        )
      end
    end

    context "given two players" do
      before do
        given_events(
          GameCreatedEvent.new(id, GameState::LOBBYING, bob),
          PlayerJoinedGameEvent.new(id, bob),
          PlayerJoinedGameEvent.new(id, steven),
          GameStartedEvent.new(id, GameState::RUNNING, deck, board),
          SpawnPlacedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          SpawnPlacedEvent.new(id, steven, GameUnit.new(3, 1, GameUnit::DOWN)),
          GoalPlacedEvent.new(id, Goal.new(2, 11, 1)),
          RobotSpawnedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          RobotSpawnedEvent.new(id, steven, GameUnit.new(3, 1, GameUnit::DOWN)),
          GameRoundStartedEvent.new(id, GameRound.new(1), { "bob" => [], "steven" => [] }, "bob" => [], "steven" => []),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(10)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.u_turn(20)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(30)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.u_turn(40)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(50)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.u_turn(60)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(70)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.rotate_left(90)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(110)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.rotate_left(130)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(150)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.rotate_left(170)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(190)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.rotate_left(210)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(230)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.rotate_left(250)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(270)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.rotate_left(290)),
          RobotProgrammedEvent.new(id, bob, [
            InstructionCard.u_turn(10),
            InstructionCard.u_turn(30),
            InstructionCard.u_turn(50),
            InstructionCard.rotate_left(70),
            InstructionCard.rotate_left(110)
          ]),
          RobotProgrammedEvent.new(id, steven, [
            InstructionCard.u_turn(20),
            InstructionCard.u_turn(40),
            InstructionCard.u_turn(60),
            InstructionCard.rotate_left(90),
            InstructionCard.rotate_left(130)
          ]),
          AllRobotsProgrammedEvent.new(id)
        )
      end

      it "plays the round" do
        when_command PlayCurrentRoundCommand.new(id: id)
        then_events(
          GameRoundStartedPlayingEvent.new(id, GameRound.new(1)),
          InstructionCardRevealedEvent.new(id, bob, InstructionCard.u_turn(10)),
          InstructionCardRevealedEvent.new(id, steven, InstructionCard.u_turn(20)),
          RobotRotatedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::UP)),
          RobotRotatedEvent.new(id, steven, GameUnit.new(3, 1, GameUnit::UP)),
          InstructionCardRevealedEvent.new(id, bob, InstructionCard.u_turn(30)),
          InstructionCardRevealedEvent.new(id, steven, InstructionCard.u_turn(40)),
          RobotRotatedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          RobotRotatedEvent.new(id, steven, GameUnit.new(3, 1, GameUnit::DOWN)),
          InstructionCardRevealedEvent.new(id, bob, InstructionCard.u_turn(50)),
          InstructionCardRevealedEvent.new(id, steven, InstructionCard.u_turn(60)),
          RobotRotatedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::UP)),
          RobotRotatedEvent.new(id, steven, GameUnit.new(3, 1, GameUnit::UP)),
          InstructionCardRevealedEvent.new(id, bob, InstructionCard.rotate_left(70)),
          InstructionCardRevealedEvent.new(id, steven, InstructionCard.rotate_left(90)),
          RobotRotatedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::LEFT)),
          RobotRotatedEvent.new(id, steven, GameUnit.new(3, 1, GameUnit::LEFT)),
          InstructionCardRevealedEvent.new(id, bob, InstructionCard.rotate_left(110)),
          InstructionCardRevealedEvent.new(id, steven, InstructionCard.rotate_left(130)),
          RobotRotatedEvent.new(id, bob, GameUnit.new(2, 1, GameUnit::DOWN)),
          RobotRotatedEvent.new(id, steven, GameUnit.new(3, 1, GameUnit::DOWN)),
          GameRoundFinishedPlayingEvent.new(id, GameRound.new(1)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(10)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(20)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(30)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(40)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(50)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(60)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(70)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(90)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(110)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(130)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(150)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(170)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(190)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(210)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(230)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(250)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(270)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(290)),
          GameRoundStartedEvent.new(id, GameRound.new(2), { "bob" => [], "steven" => [] }, "bob" => [], "steven" => []),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(310)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.rotate_left(330)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(350)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.rotate_left(370)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(390)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.rotate_left(410)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_right(80)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.rotate_right(100)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_right(120)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.rotate_right(140)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_right(160)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.rotate_right(180)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_right(200)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.rotate_right(220)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_right(240)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.rotate_right(260)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_right(280)),
          InstructionCardDealtEvent.new(id, steven, InstructionCard.rotate_right(300)),
        )
      end
    end

    context "given a winning scenario" do
      before do
        given_events(
          GameCreatedEvent.new(id, GameState::LOBBYING, bob),
          PlayerJoinedGameEvent.new(id, bob),
          GameStartedEvent.new(id, GameState::RUNNING, deck, board),
          SpawnPlacedEvent.new(id, bob, GameUnit.new(0, 0, GameUnit::DOWN)),
          GoalPlacedEvent.new(id, Goal.new(0, 0, 1)),
          RobotSpawnedEvent.new(id, bob, GameUnit.new(0, 0, GameUnit::DOWN)),
          GameRoundStartedEvent.new(id, GameRound.new(1), { "bob" => [] }, "bob" => []),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(10)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(20)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(30)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(40)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(50)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.u_turn(60)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(70)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(90)),
          InstructionCardDealtEvent.new(id, bob, InstructionCard.rotate_left(110)),
          RobotProgrammedEvent.new(id, bob, [
            InstructionCard.u_turn(10),
            InstructionCard.u_turn(20),
            InstructionCard.u_turn(30),
            InstructionCard.u_turn(40),
            InstructionCard.u_turn(50)
          ]),
          AllRobotsProgrammedEvent.new(id)
        )
      end

      it "wins the game for a player" do
        when_command PlayCurrentRoundCommand.new(id: id)
        then_events(
          GameRoundStartedPlayingEvent.new(id, GameRound.new(1)),
          InstructionCardRevealedEvent.new(id, bob, InstructionCard.u_turn(10)),
          RobotRotatedEvent.new(id, bob, GameUnit.new(0, 0, GameUnit::UP)),
          InstructionCardRevealedEvent.new(id, bob, InstructionCard.u_turn(20)),
          RobotRotatedEvent.new(id, bob, GameUnit.new(0, 0, GameUnit::DOWN)),
          InstructionCardRevealedEvent.new(id, bob, InstructionCard.u_turn(30)),
          RobotRotatedEvent.new(id, bob, GameUnit.new(0, 0, GameUnit::UP)),
          InstructionCardRevealedEvent.new(id, bob, InstructionCard.u_turn(40)),
          RobotRotatedEvent.new(id, bob, GameUnit.new(0, 0, GameUnit::DOWN)),
          InstructionCardRevealedEvent.new(id, bob, InstructionCard.u_turn(50)),
          RobotRotatedEvent.new(id, bob, GameUnit.new(0, 0, GameUnit::UP)),
          GoalTouchedEvent.new(id, bob, Goal.new(0, 0, 1)),
          PlayerWonGameEvent.new(id, bob),
          SpawnReplacedEvent.new(id, bob, GameUnit.new(0, 0, GameUnit::UP)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(10)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(20)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(30)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(40)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(50)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.u_turn(60)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(70)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(90)),
          InstructionCardDiscardedEvent.new(id, InstructionCard.rotate_left(110)),
          GameRoundFinishedPlayingEvent.new(id, GameRound.new(1)),
          GameEndedEvent.new(id, GameState::ENDED)
        )
      end
    end
  end

  describe JoinGameCommand do
    subject(:command) { JoinGameCommand.new(id: id, player_id: steven) }
    before { given_events GameCreatedEvent.new(id, GameState::LOBBYING, bob) }

    it "joins a game" do
      when_command(command)
      then_events(PlayerJoinedGameEvent.new(id, steven))
    end

    context "given the player already joined the game" do
      before { given_events PlayerJoinedGameEvent.new(id, steven) }

      it "denies joining the game again" do
        expect { dispatch(command) }.to raise_error(PlayerAlreadyInGameError)
      end
    end

    context "given the game already started" do
      before { given_events GameStartedEvent.new(id, GameState::RUNNING, deck, board) }

      it "denies joining the game" do
        expect { dispatch(command) }.to raise_error(GameAlreadyStartedError)
      end
    end
  end

  describe LeaveGameCommand do
    subject(:command) { LeaveGameCommand.new(id: id, player_id: steven) }
    before { given_events GameCreatedEvent.new(id, GameState::LOBBYING, bob) }

    context "given the player joined the game" do
      before { given_events PlayerJoinedGameEvent.new(id, steven) }

      it "leaves a game" do
        when_command(command)
        then_events(PlayerLeftGameEvent.new(id, steven))
      end

      context "and the game already started" do
        before { given_events GameStartedEvent.new(id, GameState::RUNNING, deck, board) }

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
