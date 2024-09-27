module SubmissionHistory
  class LinkToSubmissionHistoryStream
    def initialize(event_store: Rails.configuration.event_store)
      @event_store = event_store
    end

    def call(event)
      stream_name = SubmissionHistory.stream_name(
        reference_from_event(event)
      )

      @event_store.link(event.event_id, stream_name:)
    end

    private

    def reference_from_event(event)
      reference = event.data[:reference]

      reference.presence

      # app = DatastoreApi::Requests::GetApplication.new(application_id: event.data.fetch(:application_id)).call
      # app.reference
    end
  end
end
