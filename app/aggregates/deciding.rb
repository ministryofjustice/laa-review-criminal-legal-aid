module Deciding
  class DraftCreated < RailsEventStore::Event; end
  class InterestsOfJusticeSet < RailsEventStore::Event; end

  class << self
    def stream_name(decision_id)
      "Deciding$#{decision_id}"
    end
  end

  class Configuration
    def call(event_store)
      event_store.subscribe(
        DecisionHandler, to: [Reviewing::AddDecision]
      )
    end
  end

  class DecisionHandler
    def call(event); end
  end
end
