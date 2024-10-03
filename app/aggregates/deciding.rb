module Deciding
  class DecisionNotFound < StandardError; end
  class ApplicationNotAssignedToUser < StandardError; end

  class Event < RailsEventStore::Event
    class << self
      def build(decision, data = {})
        args = {
          application_id: decision.application_id,
          decision_id: decision.decision_id
        }

        new(data: args.merge(data))
      end
    end
  end

  class DraftCreated < RailsEventStore::Event; end
  class DraftLinked < RailsEventStore::Event; end
  class InterestsOfJusticeSet < RailsEventStore::Event; end
  class FundingDecisionSet < RailsEventStore::Event; end
  class SynchedWithMaat < Event; end
  class CommentSet < RailsEventStore::Event; end

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
