module ReceivedOnReports
  class Configuration
    def call(event_store)
      event_store.subscribe(
        ReceivedOnReports::LinkToReceivedOnStream.new, to: OPENING_EVENTS + CLOSING_EVENTS
      )
    end
  end
end
