module Reviewing
  class AlreadyCompleted < StandardError; end
  class AlreadyMarkedAsReady < StandardError; end
  class AlreadyReceived < StandardError; end
  class AlreadySentBack < StandardError; end
  class CannotCompleteWhenSentBack < StandardError; end
  class CannotMarkAsReadyWhenCompleted < StandardError; end
  class CannotMarkAsReadyWhenSentBack < StandardError; end
  class CannotSendBackWhenCompleted < StandardError; end
  class NotReceived < StandardError; end
end
