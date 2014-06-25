GameCreatedEvent = Struct.new(:id, :state, :host_id)

PlayerJoinedGameEvent = Struct.new(:id, :player_id)
PlayerLeftGameEvent = Struct.new(:id, :player_id)

GameStartedEvent = Struct.new(
  :id, :state, :instruction_deck, :tiles
)
SpawnPlacedEvent = Struct.new(:id, :player_id, :spawn)
SpawnReplacedEvent = Struct.new(:id, :player_id, :spawn)
GoalPlacedEvent = Struct.new(:id, :goal)
RobotSpawnedEvent = Struct.new(:id, :player_id, :robot)

GameRoundStartedEvent = Struct.new(:id, :game_round)

InstructionCardDealtEvent = Struct.new(:id, :player_id, :instruction_card)
InstructionCardDiscardedEvent = Struct.new(:id, :instruction_card)
InstructionDeckShuffledEvent = Struct.new(:id, :instruction_cards)

RobotProgrammedEvent = Struct.new(:id, :player_id, :instruction_cards)
AllRobotsProgrammedEvent = Struct.new(:id)

RobotMovedEvent = Struct.new(:id, :player_id, :robot)
RobotRotatedEvent = Struct.new(:id, :player_id, :robot)
RobotDiedEvent = Struct.new(:id, :player_id, :robot)
RobotPushedEvent = Struct.new(:id, :player_id, :robot)
GoalTouchedEvent = Struct.new(:id, :player_id, :goal)

PlayerWonGameEvent = Struct.new(:id, :player_id)
GameEndedEvent = Struct.new(:id, :state)
