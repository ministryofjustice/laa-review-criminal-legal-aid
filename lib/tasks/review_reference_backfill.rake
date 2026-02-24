desc 'Add reference to existing reviews'
task review_reference_backfill: [:environment] do
  limit = ENV['LIMIT']&.to_i
  updated = 0
  failed = 0

  Rails.logger.info "Start of review_reference_backfill task with limit: #{limit || 'none set'}"

  Review.where(reference: nil).in_batches(of: limit || 1000) do |batch|
    batch.pluck(:application_id).each do |application_id|
      Reviews::UpdateFromAggregate.new.update_from_aggregate(application_id:)
      updated += 1
    rescue StandardError => e
      failed += 1
      Rails.logger.warn "Failed to set 'reference' for #{application_id} while running review_reference_backfill"
      Rails.logger.warn e
    end
    Rails.logger.info "review_reference_backfill progress — Updated: #{updated}, Failed: #{failed}"
    break if limit
  end

  Rails.logger.info "review_reference_backfill complete — Updated: #{updated}, Failed: #{failed}"
end
