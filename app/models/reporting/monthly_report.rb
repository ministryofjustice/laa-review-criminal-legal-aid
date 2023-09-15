module Reporting
  class MonthlyReport < TemporalReport
    PARAM_FORMAT = '%Y-%B'.freeze
    INTERVAL = Types::TemporalInterval['week']
    PERIOD_NAME_FORMAT = '%B, %Y'.freeze

    # e.g. Tuesday 1 — Thursday 31 August 2023
    def period_text
      period_starts_on.strftime('%A %-d — ') +
        period_ends_on.strftime('%A %-d %B %Y')
    end

    def period_starts_on
      date.beginning_of_month
    end

    def period_ends_on
      date.end_of_month
    end

    class << self
      def next_date(date)
        date >> 1
      end

      def previous_date(date)
        date << 1
      end
    end
  end
end
