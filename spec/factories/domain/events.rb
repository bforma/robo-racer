FactoryGirl.define do
  sequence :id do
    SecureRandom.uuid
  end

  factory :player_created_event do
    id
    name "Bob"
    email "bob@localhost.local"
    password "secret"
    access_token { SecureRandom.hex }
  end

  factory :game_created_event do
    id
    state { GameState::LOBBYING }
    host_id "bob"
  end

  factory :player_joined_game_event do
    id
    player_id "bob"
  end

  factory :player_left_game_event do
    id
    player_id "bob"
  end

  factory :game_started_event do
    id
    state { GameState::RUNNING }
    instruction_deck { InstructionDeckComposer.compose }
    tiles { BoardComposer.compose(2, 2) }
  end

  factory :spawn_placed_event do
    id
    player_id "bob"
    spawn { GameUnit.new(0, 0, GameUnit::DOWN) }
  end

  factory :goal_placed_event do
    id
    goal { Goal.new(1, 1, 1) }
  end

  factory :robot_spawned_event do
    id
    player_id "bob"
    robot { GameUnit.new(0, 0, GameUnit::DOWN) }
  end

  factory :game_round_started_event do
    id
    game_round { GameRound.new(1) }
  end

  factory :instruction_card_dealt_event do
    id
    player_id "bob"
    instruction_card { InstructionCard.u_turn(10) }
  end

  factory :all_robots_programmed_event do
    id
  end

  factory :instruction_card_discarded_event do
    id
    instruction_card { InstructionCard.u_turn(10) }
  end

  factory :robot_moved_event do
    id
    player_id "bob"
    robot { GameUnit.new(0, 1, GameUnit::DOWN) }
  end

  factory :robot_rotated_event do
    id
    player_id "bob"
    robot { GameUnit.new(0, 1, GameUnit::LEFT) }
  end
end
