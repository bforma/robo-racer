class Player < ActiveRecord::Base
  devise(:database_authenticatable, :registerable)
end
