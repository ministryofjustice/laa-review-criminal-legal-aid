module ReceivedOnReports
  class LinkToReceivedOnStream
    def initialize(event_store: Rails.configuration.event_store)
      @event_store = event_store
    end

    def call(event)
      stream_name = ReceivedOnReports.stream_name(
        application_submitted_at_from_event(event)
      )

      @event_store.link(event.event_id, stream_name:)
    end

    private

    def application_submitted_at_from_event(event)
      receiving_event = submission_event_from_event(event)

      receiving_event.data.fetch(:submitted_at, receiving_event.timestamp)
    end

    def submission_event_from_event(event)
      return event if event.is_a? Reviewing::ApplicationReceived

      @event_store.read.stream(Reviewing.stream_name(
                                 event.data.fetch(:application_id)
                               )).first
    end
  end
end
