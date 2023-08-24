module CaseworkerReports
  class LinkToTemporalStreams
    def initialize(event_store: Rails.configuration.event_store)
      @event_store = event_store
    end

    def call(event)
      date = event.timestamp.in_time_zone('London').to_date

      @event_store.link [event.event_id], stream_name: date.strftime('MonthlyCaseworker$%Y-%m')
      @event_store.link [event.event_id], stream_name: date.strftime('WeeklyCaseworker$%G-%V')
      @event_store.link [event.event_id], stream_name: date.strftime('DailyCaseworker$%Y-%j')
    end
  end
end
