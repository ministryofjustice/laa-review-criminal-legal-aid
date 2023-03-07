class AddCanManageOthersToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :can_manage_others, :boolean, :default => false, null: false, index: true
  end
end
