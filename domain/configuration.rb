module RoboRacer
  class Configuration
    def self.wire_up(event_store)
      command_bus = Fountain::Command::SimpleCommandBus.new
      repository = Fountain::EventSourcing::Repository.build(
        Aggregates::Player,
        event_store
      )
      event_bus = Fountain::Event::SimpleEventBus.new
      repository.event_bus = event_bus

      player_command_handler = CommandHandlers::Player.new(repository)
      command_bus.subscribe(CreatePlayer, player_command_handler)

      command_bus
    end
  end
end
