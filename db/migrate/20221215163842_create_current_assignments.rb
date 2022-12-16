class CreateCurrentAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :current_assignments, id: false do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid, index: true
      t.uuid :assignment_id, null: false
    end

    add_index :current_assignments, :assignment_id, unique: true
  end
end
