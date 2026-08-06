module ReferenceHistory
  class Configuration
    def call(event_store)
      event_store.subscribe(
        ReferenceHistory::LinkToReferenceStream.new, to: HISTORY_EVENTS
      )
    end
  end
end
