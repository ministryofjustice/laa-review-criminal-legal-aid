module Deciding
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
end
