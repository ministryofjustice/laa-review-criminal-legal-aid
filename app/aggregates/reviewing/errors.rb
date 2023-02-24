module Reviewing
  class AlreadyReceived < StandardError
  end

  class NotReceived < StandardError
  end

  class AlreadySentBack < StandardError
  end

  class AlreadyCompleted < StandardError
  end

  class CannotCompleteWhenSentBack < StandardError
  end

  class CannotSendBackWhenCompleted < StandardError
  end
end
