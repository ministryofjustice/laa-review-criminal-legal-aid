module Reviewing
  class Error < StandardError
    def message_key
      self.class.name.demodulize.underscore.to_sym
    end
  end

  class AlreadyMarkedAsReady < Error; end
  class AlreadyReceived < Error; end
  class AlreadySentBack < Error; end
  class AlreadyReviewed < Error; end
  class DecisionAlreadyLinked < Error; end
  class DecisionNotLinked < Error; end
  class IncompleteDecisions < Error; end
  class UnexpectedAssignee < Error; end

  class DecisionAdded < Event; end
  class DecisionRemoved < Event; end

  class << self
    def stream_name(application_id)
      "Reviewing$#{application_id}"
    end

    def receiving_event(application_id)
      Rails.configuration.event_store.read.stream(stream_name(application_id)).first
    end
  end

  class Configuration
    def call(event_store)
      event_store.subscribe(Reviewing::Handlers::CompleteReview, to: [Reviewing::Completed])
    end
  end
end
