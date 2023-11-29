class AddReviewedOnToReviewReadModel < ActiveRecord::Migration[7.1]
  def up
    add_column :reviews, :reviewed_on, :date
    add_index :reviews, :reviewed_on

    Review.where(reviewed_on: nil).pluck(:application_id).each do |application_id|
      aggregate = Reviewing::LoadReview.call(application_id: application_id)
      Reviews::UpdateFromAggregate.new.update_from_aggregate(aggregate)
    rescue StandardError => e
      Rails.logger.warn "Failed to set 'reviewed_on' for #{application_id} while migrating AddReviewedOnToReviewReadModel"
      Rails.logger.warn e
    end
  end

  def down
    remove_index :reviews, :reviewed_on
    remove_column :reviews, :reviewed_on
  end
end
