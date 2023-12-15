module ReceivedOnReports
  STREAM_NAME_FORMAT = 'ReceivedOn$%Y-%j'.freeze

  OPENING_EVENTS = [
    Reviewing::ApplicationReceived
  ].freeze

  CLOSING_EVENTS = [
    Reviewing::SentBack, Reviewing::Completed
  ].freeze

  class << self
    def stream_name(date)
      BusinessDay.new(day_zero: date).date.strftime(STREAM_NAME_FORMAT)
    end
  end
end
