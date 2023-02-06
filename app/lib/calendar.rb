class Calendar < Business::Calendar
  def initialize
    super(
      name: 'LAA calendar',
      working_days: %w[mon tue wed thu fri],
      holidays: bank_holidays
    )
  end

  private

  def bank_holidays
    @bank_holidays ||= JSON.parse(
      Rails.root.join('config/data/bank-holidays.json').read
    ).dig('england-and-wales', 'events').pluck('date')
  end
end
