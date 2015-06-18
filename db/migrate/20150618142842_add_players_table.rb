class AddPlayersTable < ActiveRecord::Migration
  def change
    create_table :players, id: :uuid do |t|
      t.string :name
      t.string :email
      t.string :encrypted_password
      t.string :access_token
    end
  end
end
