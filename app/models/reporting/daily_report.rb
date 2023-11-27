module Reporting
  class DailyReport < TemporalReport
    PARAM_FORMAT = '%Y-%m-%d'.freeze
    INTERVAL = Types::TemporalInterval['daily']
    PERIOD_NAME_FORMAT = '%A %-d %B %Y'.freeze

    def period_text
      '00:00—23:59'
    end
  end
end
