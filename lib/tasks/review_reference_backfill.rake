desc 'Add reference to existing reviews via datastore'
task review_reference_backfill: [:environment] do
  limit = ENV['LIMIT']&.to_i
  updated = 0
  failed = 0

  Rails.logger.info "Start of review_reference_backfill task with limit: #{limit || 'all records'}"

  scope = Review.where(reference: nil)
  scope = scope.limit(limit) if limit

  event_store = Rails.configuration.event_store
  search = Datastore::ApplicationSearch.new

  scope.in_batches(of: 1000) do |batch|
    application_ids = batch.pluck(:application_id)
    results = search.by_application_ids(application_ids)

    references = results.each_with_object({}) do |result, hash|
      hash[result['resource_id']] = result['reference']
    end

    application_ids.each do |application_id|
      reference = references[application_id]

      unless reference
        Rails.logger.warn "review_reference_backfill: no reference found for #{application_id}, skipping"
        failed += 1
        next
      end

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

desc 'Rebuild review read models from aggregate to add missing reference'
task review_reference_rebuild: [:environment] do
  limit = ENV['LIMIT']&.to_i
  updated = 0
  failed = 0

  Rails.logger.info "Start of review_reference_rebuild task with limit: #{limit || 'all records'}"

  scope = Review.where(reference: nil)
  scope = scope.limit(limit) if limit

  scope.in_batches(of: 1000) do |batch|
    batch.pluck(:application_id).each do |application_id|
      Reviews::UpdateFromAggregate.new.update_from_aggregate(application_id:)

      updated += 1
      Rails.logger.info "review_reference_rebuild updated: #{application_id}"
    rescue StandardError => e
      failed += 1
      Rails.logger.warn "review_reference_rebuild failed for #{application_id}: #{e.message}"
    end
    Rails.logger.info "review_reference_rebuild progress — Updated: #{updated}, Failed: #{failed}"
  end

  Rails.logger.info "review_reference_rebuild complete — Updated: #{updated}, Failed: #{failed}"
end
