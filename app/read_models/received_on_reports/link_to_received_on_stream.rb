module ReceivedOnReports
  class LinkToReceivedOnStream
    def initialize(event_store: Rails.configuration.event_store)
      @event_store = event_store
    end

    def call(event)
      application_id = event.data.fetch(:application_id, nil)
      return unless application_id

      revieved_on = Reviewing::LoadReview.call(application_id:).business_day

      @event_store.link(
        event.event_id, stream_name: revieved_on.strftime(stream_name_format)
      )
    end

    def stream_name_format
      ReceivedOnReports::Configuration::STREAM_NAME_FORMAT
    end
  end
end
