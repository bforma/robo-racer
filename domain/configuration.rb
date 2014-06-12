module RoboRacer
  class Configuration
    def self.wire_up(event_store, listeners = [])
      command_bus = Fountain::Command::SimpleCommandBus.new
      player_repository = Fountain::EventSourcing::Repository.build(
        Aggregates::Player,
        event_store
      )
      event_bus = Fountain::Event::SimpleEventBus.new
      listeners.each { |listener| event_bus.subscribe(listener) }
      player_repository.event_bus = event_bus

      player_command_handler = CommandHandlers::Player.new(player_repository)
      command_bus.subscribe(CreatePlayer, player_command_handler)

      command_bus
    end
  end
end
