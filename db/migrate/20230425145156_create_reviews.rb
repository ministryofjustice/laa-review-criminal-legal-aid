class CreateReviews < ActiveRecord::Migration[7.0]
  # Create the Review read model.
  def change
    create_table :reviews, id: false do |t|
      t.uuid :application_id, null: false
      t.string :state
      t.uuid :reviewer_id
      t.uuid :parent_id
      t.timestamp :submitted_at
    end

    add_index :reviews, :application_id, unique: true
    add_index :reviews, :reviewer_id
    add_index :reviews, :parent_id
    add_index :reviews, :state
  end
end
