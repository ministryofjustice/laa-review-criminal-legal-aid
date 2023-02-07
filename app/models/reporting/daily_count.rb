module Reporting
  class DailyCount
    def initialize(filter:, number_of_days: 4, day_zero: Time.zone.now.to_date)
      @calendar = Calendar.new
      @number_of_days = number_of_days
      @day_zero = calendar.roll_forward(day_zero)
      @filter_args = filter.to_h
    end

    def periods
      [business_day_period_start_dates, business_day_period_end_dates].transpose
    end

    def counts
      filters.map { |filter| ApplicationSearch.new(filter:, pagination:).total }
    end

    def filters
      periods.map do |submitted_after, submitted_before|
        ApplicationSearchFilter.new(
          submitted_after:,
          submitted_before:,
          **@filter_args
        )
      end
    end

    def to_partial_path
      'reporting/daily_count'
    end

    private

    attr_reader :number_of_days, :day_zero, :calendar

    #
    # Array of the four most recent business days in descending order
    #
    def business_days
      @business_days ||= Array.new(number_of_days) do |i|
        calendar.subtract_business_days(day_zero, i)
      end
    end

    #
    # If a business day follows a non-working day or bank holiday
    # then the period start date is the date of the first non-working day
    # after the previous business day.
    #
    def business_day_period_start_dates
      Array.new(number_of_days) do |i|
        previous_business_day = business_days[i + 1]
        previous_business_day&.tomorrow
      end
    end

    # Array of the next period's start date or nil
    def business_day_period_end_dates
      business_day_period_start_dates.rotate(-1)
    end

    def pagination
      @pagination ||= Pagination.new(limit_value: 1)
    end
  end
end
