module Reporting
  class WeeklyReport < TemporalReport
    PARAM_FORMAT = '%G-%V'.freeze
    INTERVAL = Types::TemporalInterval['weekly']
    PERIOD_NAME_FORMAT = 'Week %-V, %G'.freeze

    def period_text
      [
        I18n.l(time_period.starts_on, format: '%A %-d %B'),
        I18n.l(time_period.ends_on, format: :reporting_long)
      ].join(' to ')
    end
  end
end
