class BusinessDay
  def initialize(day_zero: Time.current, calendar: Calendar.new)
    day_zero = day_zero.in_time_zone('London').to_date
    @calendar = calendar
    @date = calendar.roll_forward(day_zero)
  end

  def ==(other)
    date.to_s == other.to_s
  end

  attr_accessor :date

  delegate :to_s, to: :date

  def previous
    self.class.new(day_zero: calendar.subtract_business_days(date, 1))
  end

  def next
    self.class.new(day_zero: calendar.add_business_days(date, 1))
  end

  def age_in_business_days
    calendar.business_days_between(
      date, Time.current.in_time_zone('London').to_date
    )
  end

  # Returns the date of the start of a business day period
  def starts_on
    previous.date.tomorrow
  end

  # Returns the date that immediatly follows a business day period
  def ends_before
    date.tomorrow
  end

  private

  attr_reader :calendar

  class << self
    def aged(age_in_business_days)
      today = Time.current.in_time_zone('London').to_date
      day_zero = Calendar.new.subtract_business_days(today, age_in_business_days)
      new(day_zero:)
    end

    def list_backwards(day_zero: Time.current, age_limit: 9)
      day_zero_business_day = new(day_zero:)

      business_days = [day_zero_business_day]

      age_limit.times do
        business_days << business_days.last.previous
      end

      business_days
    end
  end
end
