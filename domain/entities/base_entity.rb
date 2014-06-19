class BaseEntity
  include Fountain::EventSourcing::Entity

  def initialize(aggregate_root)
    self.aggregate_root = aggregate_root
  end
end
