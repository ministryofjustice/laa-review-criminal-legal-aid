class AddAppplicationTypeToReviewReadModel < ActiveRecord::Migration[7.1]
  def change
    add_column :reviews, :application_type, :string, default: Types::ApplicationType['initial']
    add_index :reviews, :application_type
  end
end
