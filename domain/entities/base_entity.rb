class BaseEntity
  include Fountain::EventSourcing::Entity

  private

  def id
    aggregate_root.id
  end
end
