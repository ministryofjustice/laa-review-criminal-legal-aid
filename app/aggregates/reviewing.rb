module Reviewing
  class Error < StandardError
    def message_key
      self.class.name.demodulize.underscore.to_sym
    end
  end

  class AlreadyCompleted < Error; end
  class AlreadyMarkedAsReady < Error; end
  class AlreadyReceived < Error; end
  class AlreadySentBack < Error; end
  class DecisionAlreadyLinked < Error; end
  class CannotCompleteWhenSentBack < Error; end
  class CannotMarkAsReadyWhenCompleted < Error; end
  class CannotMarkAsReadyWhenSentBack < Error; end
  class CannotSendBackWhenCompleted < Error; end
  class IncompleteDecisions < Error; end
  class NotReceived < Error; end

  class DecisionAdded < Event; end
  class MaatDecisionAdded < Event; end

  class << self
    def stream_name(application_id)
      "Reviewing$#{application_id}"
    end

    def receiving_event(application_id)
      Rails.configuration.event_store.read.stream(stream_name(application_id)).first
    end
  end
end
