module Reporting
  class WeeklyReport < TemporalReport
    PARAM_FORMAT = '%G-%V'.freeze
    INTERVAL = Types::TemporalInterval['weekly']
    PERIOD_NAME_FORMAT = 'Week %-V, %G'.freeze

    def period_text
      [
        I18n.l(time_period.starts_on, format: start_date_format),
        I18n.l(time_period.ends_on, format: :reporting_long)
      ].join(' to ')
    end

    private

    def start_date_format
      return :reporting_long if time_period.starts_on.year != time_period.ends_on.year

      '%A %-d %B'
    end
  end
end
