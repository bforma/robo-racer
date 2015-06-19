GameWasCreated = Struct.new(:id, :state, :host_id)

PlayerJoinedGame = Struct.new(:id, :player_id)
PlayerLeftGame = Struct.new(:id, :player_id)

GameStarted = Struct.new(:id, :state, :instruction_deck, :tiles)
SpawnPlaced = Struct.new(:id, :player_id, :spawn)
SpawnReplaced = Struct.new(:id, :player_id, :spawn)
GoalPlaced = Struct.new(:id, :goal)
RobotSpawned = Struct.new(:id, :player_id, :robot)

GameRoundStarted = Struct.new(:id, :game_round, :hands, :programs)

InstructionCardDealt = Struct.new(:id, :player_id, :instruction_card)
InstructionCardDiscarded = Struct.new(:id, :instruction_card)
InstructionDeckShuffled = Struct.new(:id, :instruction_cards)

RobotProgrammed = Struct.new(:id, :player_id, :instruction_cards)
AllRobotsProgrammed = Struct.new(:id)

GameRoundStartedPlaying = Struct.new(:id, :game_round)
InstructionCardRevealed = Struct.new(:id, :player_id, :instruction_card)
GameRoundFinishedPlaying = Struct.new(:id, :game_round)

RobotMoved = Struct.new(:id, :player_id, :robot)
RobotRotated = Struct.new(:id, :player_id, :robot)
RobotDied = Struct.new(:id, :player_id, :robot)
RobotPushed = Struct.new(:id, :player_id, :robot)
GoalTouched = Struct.new(:id, :player_id, :goal)

PlayerWonGame = Struct.new(:id, :player_id)
GameEnded = Struct.new(:id, :state)
