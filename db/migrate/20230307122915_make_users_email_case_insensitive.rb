class MakeUsersEmailCaseInsensitive < ActiveRecord::Migration[7.0]
  def up
    enable_extension 'citext'
    change_column :users, :email, :citext
    add_index :users, :email, unique: true
    add_index :users, :auth_subject_id, unique: true
  end

  def down
    change_column :users, :email, :string
    disable_extension 'citext'
  end
end
