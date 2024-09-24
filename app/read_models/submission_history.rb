module SubmissionHistory
  EVENT_TYPES = [
    Reviewing::ApplicationReceived,
    Reviewing::SentBack,
    Reviewing::Completed
  ].freeze

  class << self
    def stream_name(reference)
      "SubmissionHistory$#{reference}"
    end
  end
end
