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
  class CannotCompleteWhenSentBack < Error; end
  class CannotMarkAsReadyWhenCompleted < Error; end
  class CannotMarkAsReadyWhenSentBack < Error; end
  class CannotSendBackWhenCompleted < Error; end
  class NotReceived < Error; end

  class << self
    def stream_name(application_id)
      "Reviewing$#{application_id}"
    end
  end
end
