class AddReviewedOnToReviewReadModel < ActiveRecord::Migration[7.1]
  def up
    add_column :reviews, :work_stream, :string, default: Types::WorkStreamType['criminal_applications_team']
    add_index :reviews, :work_stream

    add_column :reviews, :reviewed_on, :date
    add_index :reviews, :reviewed_on

    Review.pluck(:application_id).each do |application_id|
      aggregate = Reviewing::LoadReview.call(application_id: application_id)
      Reviews::UpdateFromAggregate.new.update_from_aggregate(aggregate)
    rescue StandardError => e
      Rails.logger.warn "Failed to set 'work_stream', reviewed_on' for #{application_id} while migrating AddReviewedOnToReviewReadModel"
      Rails.logger.warn e
    end
  end

  def down
    remove_index :reviews, :reviewed_on
    remove_column :reviews, :reviewed_on

    remove_index :reviews, :work_stream
    remove_column :reviews, :work_stream
  end
end
