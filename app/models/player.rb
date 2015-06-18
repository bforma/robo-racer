class Player < ActiveRecord::Base
  devise(:database_authenticatable, :registerable)

  alias_attribute :_id, :id # Mongo legacy
end
