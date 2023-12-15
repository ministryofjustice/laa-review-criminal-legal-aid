module ReceivedOnReports
  class LinkToReceivedOnStream
    def initialize(event_store: Rails.configuration.event_store)
      @event_store = event_store
    end

    def call(event)
      stream_name = ReceivedOnReports.stream_name(
        receiving_event(event).data[:submitted_at]
      )

      @event_store.link(event.event_id, stream_name:)
    end

    private

    def receiving_event(event)
      return event if event.is_a? Reviewing::ApplicationReceived

      Reviewing.receiving_event(event.data.fetch(:application_id))
    end
  end
end
