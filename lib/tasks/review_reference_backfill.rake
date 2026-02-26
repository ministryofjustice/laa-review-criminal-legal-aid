desc 'Add reference to existing reviews'
task review_reference_backfill: [:environment] do
  limit = ENV['LIMIT']&.to_i
  updated = 0
  failed = 0

  Rails.logger.info "Start of review_reference_backfill task with limit: #{limit || 'all records'}"

  scope = Review.where(reference: nil)
  scope = scope.limit(limit) if limit

  event_store = Rails.configuration.event_store

  scope.in_batches(of: 1000) do |batch|
    batch.pluck(:application_id).each do |application_id|
      reference = DatastoreApi::Requests::GetApplication.new(application_id:).call.reference

      event_store.publish(
        Reviewing::ReferenceAdded.new(data: { application_id:, reference: }),
        stream_name: Reviewing.stream_name(application_id)
      )

      updated += 1
      Rails.logger.info "review_reference_backfill updated: #{application_id}"
    rescue StandardError => e
      failed += 1
      Rails.logger.warn "review_reference_backfill failed for #{application_id}: #{e.message}"
    end
    Rails.logger.info "review_reference_backfill progress — Updated: #{updated}, Failed: #{failed}"
  end

  Rails.logger.info "review_reference_backfill complete — Updated: #{updated}, Failed: #{failed}"
end
