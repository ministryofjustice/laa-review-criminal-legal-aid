class AddCanManageOthersToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :can_manage_others, :boolean, :default => false, null: false, index: true

    # Remove as this isn't available
    # at the time of user creation
    change_column_null :users, :auth_oid, true
  end
end
