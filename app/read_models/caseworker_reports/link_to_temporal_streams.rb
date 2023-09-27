module CaseworkerReports
  class LinkToTemporalStreams
    def initialize(event_store: Rails.configuration.event_store)
      @event_store = event_store
    end

    def call(event)
      date = event.timestamp.in_time_zone('London').to_date

      stream_name_formats.each_value do |format|
        @event_store.link [event.event_id], stream_name: date.strftime(format)
      end
    end

    def stream_name_formats
      CaseworkerReports::Configuration::STREAM_NAME_FORMATS
    end
  end
end
