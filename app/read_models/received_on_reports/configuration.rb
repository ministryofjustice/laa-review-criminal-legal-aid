module ReceivedOnReports
  class Configuration
    OPENING_EVENTS = [
      Reviewing::ApplicationReceived
    ].freeze

    CLOSING_EVENTS = [
      Reviewing::SendBack, Reviewing::Completed
    ].freeze

    def call(event_store)
      event_store.subscribe(
        ReceivedOnReports::ReceiveApplication, to: OPENING_EVENTS
      )

      event_store.subscribe(
        ReceivedOnReports::CloseApplication, to: CLOSING_EVENTS
      )
    end
  end
end
