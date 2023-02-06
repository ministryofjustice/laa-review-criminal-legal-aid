module Reporting
  class DailyCount
    def initialize(filter:, rows: 4, today: Time.zone.now.to_date)
      @days = Array.new(rows) { |n| today - n.days }
      @filter_args = filter.to_h
    end

    def counts
      filters.map do |filter|
        ApplicationSearch.new(filter:, pagination:).total
      end
    end

    def filters
      days.map do |day|
        submitted_before = day.tomorrow
        submitted_after = day == final_day ? nil : day

        ApplicationSearchFilter.new(submitted_after:, submitted_before:, **filter_args)
      end
    end

    def to_partial_path
      'reporting/daily_count'
    end

    private

    attr_reader :days, :filter_args

    def final_day
      days.last
    end

    def pagination
      Pagination.new(limit_value: 1)
    end
  end
end
