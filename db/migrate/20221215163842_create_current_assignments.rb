class CreateCurrentAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :current_assignments, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid, index: true
      t.uuid :assignment_id, null: false

      t.timestamps
    end

    add_index :current_assignments, :assignment_id, unique: true
  end
end
