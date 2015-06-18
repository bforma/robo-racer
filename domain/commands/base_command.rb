class BaseCommand
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  attr_accessor :id

  validates_presence_of :id

  def ==(other)
    return false if other.nil?
    instance_values == other.instance_values
  end
end

class Command < BaseCommand
  attr_accessor :player_id

  validates_presence_of :player_id
end
