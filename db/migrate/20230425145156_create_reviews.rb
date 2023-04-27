class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews, id: false do |t|
      t.uuid :application_id, null: false
      t.uuid :reviewer_id
      t.timestamp :submitted_at
    end
    add_index :reviews, :application_id, unique: true
  end
end
