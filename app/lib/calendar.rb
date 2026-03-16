class Calendar < Business::Calendar
  def initialize
    super(
      name: 'LAA calendar',
      working_days: %w[mon tue wed thu fri],
      holidays: Govuk::BankHolidays.call.to_a
    )
  end
end
