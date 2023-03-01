class AddLastAuthAtToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :last_auth_at, :timestamp
    add_column :users, :first_auth_at, :timestamp
  end
end
