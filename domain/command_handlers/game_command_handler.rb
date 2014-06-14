class GameCommandHandler < BaseCommandHandler
  route CreateGameCommand do |command|
    game = GameAggregate.new(command.id, command.player_id)
    repository.add(game)
  end

  route JoinGameCommand do |command|
    with_aggregate(command.id) do |game|
      game.join(command.player_id)
    end
  end

  route LeaveGameCommand do |command|
    with_aggregate(command.id) do |game|
      game.leave(command.player_id)
    end
  end

  route StartGameCommand do |command|
    with_aggregate(command.id) do |game|
      game.start(command.player_id)
    end
  end

  route MoveRobotCommand do |command|
    with_aggregate(command.id) do |game|
      game.move_robot(command.speed)
    end
  end
end
