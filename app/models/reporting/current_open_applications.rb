module Reporting
  class CurrentOpenApplications
    def initialize(days: 4)
      @days = days
    end

    attr_reader :days

    def counts
      filters.map do |filter| 
        ApplicationSearch.new(filter:, pagination:).total
      end
    end

    def filters
      days.times.map do |n|
        day = n.days.ago

        submitted_after = nil

        final_day = days == (n + 1)
        
        unless final_day
          submitted_after = day.beginning_of_day.to_s
        end

        submitted_before = day.end_of_day.to_s

        ApplicationSearchFilter.new(
          submitted_after: ,
          submitted_before:,
          application_status: 'open'
        )
      end
    end

    def pagination
      Pagination.new(limit_value: 1)
    end
  end
end
