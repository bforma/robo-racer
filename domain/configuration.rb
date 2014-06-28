module RoboRacer
  class Gateway
    attr_reader :event_store, :listeners

    def initialize(event_store, listeners = [])
      @event_store = event_store
      @listeners = listeners

      init_command_bus
    end

    def dispatch(command)
      envelope = Fountain::Envelope.as_envelope(command)
      command_bus.dispatch(envelope, command_callback)
    end

    def command_bus
      @command_bus ||= Fountain::Command::SimpleCommandBus.new.tap do |commands|
        @commands = commands
        listeners.each { |listener| event_bus.subscribe(listener) }

        wire_commands(PlayerAggregate, PlayerCommandHandler, [
          CreatePlayerCommand
        ])

        wire_commands(GameAggregate, GameCommandHandler, [
          CreateGameCommand,
          JoinGameCommand,
          LeaveGameCommand,
          StartGameCommand,
          ProgramRobotCommand,
          PlayCurrentRoundCommand,
          MoveRobotCommand
        ])
      end
    end

    def event_bus
      @event_bus ||= Fountain::Event::SimpleEventBus.new
    end

    def command_callback
      @command_callback ||= DefaultCommandCallback.new
    end

  private

    def init_command_bus
      command_bus
    end

    def wire_commands(aggregate_class, handler_class, commands)
      Fountain::EventSourcing::Repository.build(aggregate_class, @event_store).tap do |repository|
        repository.event_bus = event_bus
        handler = handler_class.new(repository)
        commands.each { |command| @commands.subscribe(command, handler) }
      end
    end
  end
end
