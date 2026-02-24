class AddReferenceToReviewReadModel < ActiveRecord::Migration[7.2]
  def up
    add_column :reviews, :reference, :string
    add_index :reviews, :reference
  end

  def down
    remove_index :reviews, :reference
    remove_column :reviews, :reference
  end
end