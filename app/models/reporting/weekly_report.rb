module Reporting
  class WeeklyReport < TemporalReport
    PARAM_FORMAT = '%G-%V'.freeze
    INTERVAL = Types::TemporalInterval['weekly']
    PERIOD_NAME_FORMAT = 'Week %-V, %G'.freeze

    def period_text
      [
        I18n.l(period_starts_on, format: :reporting_long),
        I18n.l(period_ends_on, format: :reporting_long)
      ].join(' — ')
    end

    def period_starts_on
      date.beginning_of_week
    end

    def period_ends_on
      date.end_of_week
    end

    class << self
      def next_date(date)
        date + 7
      end

      def previous_date(date)
        date - 7
      end
    end
  end
end
