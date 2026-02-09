class AddReferenceToReviewReadModel < ActiveRecord::Migration[7.2]
  def up
    add_column :reviews, :reference, :integer
    add_index :reviews, :reference

    Review.pluck(:application_id).each do |application_id|
      Reviews::UpdateFromAggregate.new.update_from_aggregate(application_id:)
    rescue StandardError => e
      Rails.logger.warn "Failed to set 'reference' for #{application_id} while migrating AddReferenceToReviewReadModel"
      Rails.logger.warn e
    end
  end

  def down
    remove_index :reviews, :reference
    remove_column :reviews, :reference
  end
end
