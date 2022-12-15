class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :auth_oid, null: false
      t.string :email
      t.string :first_name
      t.string :last_name
      t.timestamps
    end

    add_index :users, :auth_oid, unique: true
  end
end
