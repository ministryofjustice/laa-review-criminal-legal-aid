module ReceivedOnReports
  class LinkToReceivedOnStream
    def initialize(event_store: Rails.configuration.event_store)
      @event_store = event_store
    end

    def call(event)
      @event_store.link(event.event_id, stream_name: stream_name(event))
    end

    private

    def stream_name(event)
      received_on(event).strftime(stream_name_format)
    end

    def received_on(event)
      day_zero = receiving_event(event).data.fetch(
        :submitted_at, receiving_event(event).timestamp
      )

      BusinessDay.new(day_zero:).date
    end

    def receiving_event(event)
      return event if event.is_a? Reviewing::ApplicationReceived

      @event_store.read.stream(
        Reviewing.stream_name(event.data.fetch(:application_id))
      ).first
    end

    def stream_name_format
      ReceivedOnReports::Configuration::STREAM_NAME_FORMAT
    end
  end
end
