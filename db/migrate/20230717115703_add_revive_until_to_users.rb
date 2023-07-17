class AddReviveUntilToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :revive_until, :datetime
  end
end
