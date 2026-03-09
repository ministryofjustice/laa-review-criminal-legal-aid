desc 'Link Assigning/Reviewing/Deciding events into the ReferenceHistory stream by reference'
task reference_history_backfill: :environment do
  limit = ENV['LIMIT']&.to_i
  START_AFTER = ENV['START_AFTER']

  linked = 0
  skipped = 0
  already_linked = 0
  errored = 0
  processed = 0
  last_application_id = nil

  Rails.logger.info "Start of reference_history_backfill task with limit: #{limit || 'all records'}, START_AFTER: #{START_AFTER || 'none'}"

  event_store = Rails.configuration.event_store

  scope = Review.order(:application_id)
  scope = scope.where('application_id > ?', START_AFTER) if START_AFTER
  scope = scope.limit(limit) if limit

  scope.in_batches(of: 1000) do |batch|
    batch.pluck(:application_id, :reference).each do |application_id, reference|
      last_application_id = application_id
      target_stream = ReferenceHistory.stream_name(reference)

      source_streams = [
        Assigning.stream_name(application_id),
        Reviewing.stream_name(application_id),
        Deciding.stream_name(application_id)
      ]

      source_streams.each do |source_stream|
        event_store.read.stream(source_stream).each do |event|
          unless ReferenceHistory::HISTORY_EVENTS.include?(event.class)
            skipped += 1
            Rails.logger.warn "reference_history_backfill skipped for #{event.class}"
            next
          end

          begin
            event_store.link(event.event_id, stream_name: target_stream)
            linked += 1
          rescue RubyEventStore::EventDuplicatedInStream
            already_linked += 1
          rescue StandardError => e
            errored += 1
            Rails.logger.warn(
              "reference_history_backfill: could not link #{event.event_id} " \
                "(#{event.class}) from #{source_stream} => #{target_stream}: " \
                "#{e.class}: #{e.message}"
            )
          end
        end
      end

      processed += 1
    rescue StandardError => e
      errored += 1
      Rails.logger.warn "reference_history_backfill failed for #{application_id}: #{e.message}"
    end
    Rails.logger.info "reference_history_backfill progress — Last application_id: #{last_application_id}, Processed: #{processed}, Linked: #{linked}, Already linked: #{already_linked}, Skipped: #{skipped}, Errors: #{errored}"
  end

  Rails.logger.info "reference_history_backfill complete — Last application_id: #{last_application_id}, Processed: #{processed}, Linked: #{linked}, Already linked: #{already_linked}, Skipped: #{skipped}, Errors: #{errored}"
end