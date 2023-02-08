module Reporting
  class DailyCount
    def initialize(filter:, number_of_days: 4, day_zero: Time.zone.now.to_date)
      @calendar = Calendar.new
      @number_of_days = number_of_days
      @day_zero = calendar.roll_forward(day_zero)
      @filter_args = filter.to_h
    end

    def counts
      filters.map { |filter| ApplicationSearch.new(filter:, pagination:).total }
    end

    #
    # Search filters for each of the business day periods.
    # The oldest day count includes all records on and before that day.
    #
    def filters
      business_days.map do |day|
        is_oldest_day = day.age_in_business_days == number_of_days - 1

        ApplicationSearchFilter.new(
          submitted_after: is_oldest_day ? nil : day.period_starts_on,
          submitted_before: day.period_ends_before,
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
      @business_days ||= Array.new(number_of_days) do |age_in_business_days|
        BusinessDay.new(age_in_business_days:, day_zero:, calendar:)
      end
    end

    def pagination
      @pagination ||= Pagination.new(limit_value: 1)
    end
  end
end
