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

    def business_days
      @business_days ||= Array.new(number_of_days) do |i|
        calendar.subtract_business_days(day_zero, i)
      end
    end

    def business_day_period_start_dates
      business_days.each_with_index.map do |_day, i|
        business_days[i + 1]&.tomorrow
      end
    end

    def business_day_period_end_dates
      business_day_period_start_dates.rotate(-1)
    end

    def pagination
      @pagination ||= Pagination.new(limit_value: 1)
    end
  end
end
