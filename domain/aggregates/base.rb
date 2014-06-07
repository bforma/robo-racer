module RoboRacer
  module Aggregates
    class Base
      include Fountain::EventSourcing::AggregateRoot
    end
  end
end
