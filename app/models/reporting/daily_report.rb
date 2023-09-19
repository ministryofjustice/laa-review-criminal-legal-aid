module Reporting
  class DailyReport < TemporalReport
    PARAM_FORMAT = '%Y-%m-%d'.freeze
    INTERVAL = Types::TemporalInterval['daily']
    PERIOD_NAME_FORMAT = '%A %-d %B %Y'.freeze

    def period_text
      '00:00—23:59'
    end

    def period_starts_on
      date
    end

    def period_ends_on
      date
    end

    class << self
      def next_date(date)
        date + 1
      end

      def previous_date(date)
        date - 1
      end
    end
  end
end
