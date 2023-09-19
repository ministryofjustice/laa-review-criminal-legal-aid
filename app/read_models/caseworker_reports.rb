module CaseworkerReports
  STREAM_NAME_FORMATS = ActiveSupport::HashWithIndifferentAccess.new(
    monthly: 'MonthlyCaseworker$%Y-%m',
    weekly: 'WeeklyCaseworker$%G-%V',
    daily: 'DailyCaseworker$%Y-%j'
  ).freeze
end
