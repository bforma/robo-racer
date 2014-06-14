class BaseCommand
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  attr_accessor :id

  validates_presence_of :id
end
