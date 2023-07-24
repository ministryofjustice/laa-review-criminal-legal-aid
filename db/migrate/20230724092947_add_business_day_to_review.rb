class AddBusinessDayToReview < ActiveRecord::Migration[7.0]
  def up
    add_column :reviews, :business_day, :date
    add_index :reviews, :business_day

    Review.where(business_day: nil).pluck(:application_id).each do |application_id|
      aggregate = Reviewing::LoadReview.call(application_id: application_id)
      Reviews::UpdateFromAggregate.new.update_from_aggregate(aggregate)
    rescue StandardError => e
      Rails.logger.warn "Failed to set Business Date for #{application_id} while migrating AddBusinessDayToReview"
      Rails.logger.warn e
    end
  end

  def down
    remove_index :reviews, :business_day
    remove_column :reviews, :business_day
  end
end
