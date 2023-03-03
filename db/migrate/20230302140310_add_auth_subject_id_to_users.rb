class AddAuthSubjectIdToUsers < ActiveRecord::Migration[7.0]
  def change
    # 
    # Allow users to be created before authentication.
    #
    change_column_null :users, :auth_oid, true

    # 
    # Store and index a users subject claim (sub). 
    #
    add_column :users, :auth_subject_id, :string

    # 
    # Remvoe oid index 
    #
    remove_index :users, :auth_oid
  end
end
