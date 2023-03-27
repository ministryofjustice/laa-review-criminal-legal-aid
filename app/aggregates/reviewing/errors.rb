module Reviewing
  class AlreadyReceived < StandardError
  end

  class NotReceived < StandardError
  end

  class AlreadySentBack < StandardError
  end

  class AlreadyCompleted < StandardError
  end

  class AlreadyMarkedAsReady < StandardError
  end

  class CannotCompleteWhenSentBack < StandardError
  end

  class CannotMarkAsReadyWhenSentBack < StandardError
  end

  class CannotSendBackWhenCompleted < StandardError
  end

  class CannotSendBackWhenMarkedAsReady < StandardError
  end

  class CannotMarkAsReadyWhenCompleted < StandardError
  end
end
