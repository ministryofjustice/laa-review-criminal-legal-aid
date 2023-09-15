module CaseworkerReports
  STREAM_NAME_FORMATS = ActiveSupport::HashWithIndifferentAccess.new(
    month: 'MonthlyCaseworker$%Y-%m',
    week: 'WeeklyCaseworker$%G-%V',
    day: 'DailyCaseworker$%Y-%j'
  ).freeze
end
