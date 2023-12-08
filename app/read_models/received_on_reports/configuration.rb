module ReceivedOnReports
  class Configuration
    STREAM_NAME_FORMAT = 'ReceivedOn$%Y-%j'.freeze

    OPENING_EVENTS = [
      Reviewing::ApplicationReceived
    ].freeze

    CLOSING_EVENTS = [
      Reviewing::SentBack, Reviewing::Completed
    ].freeze

    def call(event_store)
      event_store.subscribe(
        ReceivedOnReports::LinkToReceivedOnStream, to: OPENING_EVENTS + CLOSING_EVENTS
      )
    end
  end
end
