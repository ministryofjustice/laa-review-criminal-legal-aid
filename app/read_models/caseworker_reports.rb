module CaseworkerReports
  STREAM_NAME_FORMATS = ActiveSupport::HashWithIndifferentAccess.new(
    monthly: 'MonthlyCaseworker$%Y-%m',
    weekly: 'WeeklyCaseworker$%G-%V',
    daily: 'DailyCaseworker$%Y-%j'
  ).freeze

  class << self
    def stream_name(interval:, date:)
      format = STREAM_NAME_FORMATS.fetch(interval)
      date.in_time_zone('London').to_date.strftime(format)
    end
  end
end
