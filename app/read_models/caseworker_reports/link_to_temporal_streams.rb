module CaseworkerReports
  class LinkToTemporalStreams
    def initialize(event_store: Rails.configuration.event_store)
      @event_store = event_store
    end

    def call(event)
      date = event.timestamp.in_time_zone('London').to_date

      Types::TemporalInterval.values.each do |interval| # rubocop:disable Style/HashEachMethods
        @event_store.link(
          [event.event_id],
          stream_name: CaseworkerReports.stream_name(date:, interval:)
        )
      end
    end
  end
end
