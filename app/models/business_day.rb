class BusinessDay
  def initialize(age_in_business_days: 0, day_zero: Time.zone.now.to_date, calendar: Calendar.new)
    @age_in_business_days = age_in_business_days
    @day_zero = day_zero
    @calendar = calendar
  end

  attr_reader :age_in_business_days

  def date
    return calendar.roll_forward(day_zero).to_date if age_in_business_days.zero?

    calendar.subtract_business_days(day_zero, age_in_business_days)
  end

  #
  # The start of the date period whithin which an event's age in business days
  # should be counted as #age_in_business_days.
  #
  def period_starts_on
    previous_business_day.tomorrow
  end

  def period_ends_before
    date.tomorrow
  end

  private

  attr_reader :calendar, :day_zero

  def previous_business_day
    calendar.subtract_business_days(day_zero, age_in_business_days + 1)
  end
end
