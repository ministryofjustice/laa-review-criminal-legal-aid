class BusinessDay
  def initialize(day_zero: Time.current, age_in_business_days: 0, calendar: Calendar.new)
    @age_in_business_days = age_in_business_days
    @day_zero = day_zero.in_time_zone('London').to_date
    @calendar = calendar
  end

  attr_reader :age_in_business_days

  def date
    return calendar.roll_forward(day_zero) if age_in_business_days.zero?

    calendar.subtract_business_days(day_zero, age_in_business_days)
  end

  def business_days_since_day_zero
    calendar.business_days_between(day_zero, Time.current.in_time_zone('London').to_date)
  end

  private

  attr_reader :calendar, :day_zero
end
