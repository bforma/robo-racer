GameCreatedEvent = Struct.new(:id, :state, :host_id)
PlayerJoinedGameEvent = Struct.new(:id, :player_id)
PlayerLeftGameEvent = Struct.new(:id, :player_id)
GameStartedEvent = Struct.new(:id, :state, :instruction_deck)
GameRoundStartedEvent = Struct.new(:id, :game_round)
InstructionCardDealtEvent = Struct.new(:id, :player_id, :card)

RobotMovedEvent = Struct.new(:id, :new_position)
