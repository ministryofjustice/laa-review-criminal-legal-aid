module Reporting
  class WorkloadReport
    # Builds a Workload Report from "observed_at" until "age_limit" business days
    # ago.
    #
    # If the "number_of_rows" limit is set to be less than the number of rows
    # required to accommodate 1 business day per row, the remaining days are
    # combined into the final row. For example:
    #   "0 days", "1 day", "2 days", "Between 3 and 9 days"
    #
    def initialize(observed_at: Time.current, age_limit: 9, number_of_rows: 5)
      @observed_at = observed_at
      @age_limit = age_limit
      @number_of_rows = number_of_rows || (age_limit + 1)
    end

    attr_reader :observed_at

    def rows
      @rows ||= Array.new(@number_of_rows) do |row|
        BusinessDayAgeRangeRow.new(
          age_range_in_business_days: age_range_for_row(row),
          observed_at: observed_at
        )
      end
    end

    private

    def age_range_for_row(row_index)
      min_age = row_index
      max_age = last_row?(row_index) ? @age_limit : min_age

      min_age..max_age
    end

    def last_row?(row_index)
      row_index == @number_of_rows - 1
    end
  end
end
