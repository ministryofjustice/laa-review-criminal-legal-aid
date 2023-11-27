module Reporting
  class MonthlyReport < TemporalReport
    PARAM_FORMAT = '%Y-%B'.freeze
    INTERVAL = Types::TemporalInterval['monthly']
    PERIOD_NAME_FORMAT = '%B, %Y'.freeze

    def period_text
      time_period.starts_on.strftime('%A %-d — ') + time_period.ends_on.strftime('%A %-d %B %Y')
    end
  end
end
