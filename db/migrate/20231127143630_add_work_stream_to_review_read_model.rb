class AddWorkStreamToReviewReadModel < ActiveRecord::Migration[7.1]
  def change
    add_column :reviews, :work_stream, :string, default: Types::WorkStreamType['criminal_applications_team']
    add_index :reviews, :work_stream
  end
end
