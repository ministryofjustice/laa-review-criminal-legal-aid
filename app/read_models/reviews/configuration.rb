module Reviews
  class Configuration
    def call(event_store)
      @event_store = event_store

      subscribe(
        ->(event) { receive_application(event) },
        [Reviewing::ApplicationReceived]
      )

      subscribe(
        ->(event) { close_application(event) },
        [Reviewing::SentBack, Reviewing::Completed]
      )
    end

    private

    def subscribe(handler, events)
      @event_store.subscribe(handler, to: events)
    end

    def receive_application(event)
      application_id = event.data.fetch(:application_id)
      submitted_at = event.data.fetch(:submitted_at)

      Review.upsert(
        { application_id:, submitted_at: },
        unique_by: :application_id
      )
    end

    def close_application(event)
      application_id = event.data.fetch(:application_id)
      reviewer_id = event.data.fetch(:user_id)

      Review.upsert(
        { application_id:, reviewer_id: },
        unique_by: :application_id
      )
    end
  end
end
