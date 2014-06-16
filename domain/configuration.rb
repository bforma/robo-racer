module RoboRacer
  class Configuration
    def self.wire_up(event_store, listeners = [])
      @event_store = event_store

      Fountain::Command::SimpleCommandBus.new.tap do |commands|
        @commands = commands
        @events = Fountain::Event::SimpleEventBus.new
        listeners.each { |listener| @events.subscribe(listener) }

        wire_commands(PlayerAggregate, PlayerCommandHandler, [
          CreatePlayer
        ])
        
        wire_commands(GameAggregate, GameCommandHandler, [
          CreateGameCommand,
          JoinGameCommand,
          LeaveGameCommand,
          StartGameCommand,
          ProgramRobotCommand,
          MoveRobotCommand
        ])
      end
    end

    def self.wire_commands(aggregate_class, handler_class, commands)
      Fountain::EventSourcing::Repository.build(aggregate_class, @event_store).tap do |repository|
        repository.event_bus = @events
        handler = handler_class.new(repository)
        commands.each { |command| @commands.subscribe(command, handler) }
      end
    end
  end
end
