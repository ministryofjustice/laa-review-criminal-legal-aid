module CaseworkerReports
  # CaseworkerReports read model event store configuration
  #
  # Links caseworker report related events to day, week, and month streams.
  #
  class Configuration
    READ_MODEL_CHANGING_EVENTS = [
      Assigning::AssignedToUser,
      Assigning::ReassignedToUser,
      Assigning::UnassignedFromUser,
      Reviewing::SentBack,
      Reviewing::Completed
    ].freeze

    def call(event_store)
      event_store.subscribe(
        CaseworkerReports::LinkToTemporalStreams, to: READ_MODEL_CHANGING_EVENTS
      )
    end
  end
end
