class LinkToSubmissionHistory < ActiveRecord::Migration[7.2]
  def up
    link = SubmissionHistory::LinkToSubmissionHistoryStream.new

    Rails.configuration.event_store.read.in_batches.each_batch do |batch|
      # do something with given batch of events of default size

      batch.each do |event|
        next unless SubmissionHistory::EVENT_TYPES.member?(event.class)

        begin
          link.call(event)
        rescue  RubyEventStore::EventDuplicatedInStream
          # Ignored
        end
      end
    end
  end
end
