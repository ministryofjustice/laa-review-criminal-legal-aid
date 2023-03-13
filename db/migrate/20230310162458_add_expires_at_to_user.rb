class AddExpiresAtToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :auth_expires_at, :datetime
  end
end
