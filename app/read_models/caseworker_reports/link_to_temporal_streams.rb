module CaseworkerReports
  class LinkToTemporalStreams
    def initialize(event_store: Rails.configuration.event_store)
      @event_store = event_store
    end

    def call(event)
      date = event.timestamp.in_time_zone('London').to_date

      STREAM_NAME_FORMATS.each_value do |format|
        stream_name = date.strftime(format)
        @event_store.link [event.event_id], stream_name:
      end
    end
  end
end
