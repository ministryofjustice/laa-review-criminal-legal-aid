module Reviews
  # Review read model event store configuration
  #
  # Subscribe the Review read model's UpdateFromAggregate handler to
  # the required Reviewing event.
  #
  class Configuration
    READ_MODEL_CHANGING_EVENTS = [
      Reviewing::ApplicationReceived,
      Reviewing::ReferenceAdded,
      Reviewing::SentBack,
      Reviewing::Completed
    ].freeze

    def call(event_store)
      event_store.subscribe(
        Reviews::UpdateFromAggregate, to: READ_MODEL_CHANGING_EVENTS
      )
    end
  end
end
