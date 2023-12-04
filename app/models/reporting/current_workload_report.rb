module Reporting
  class CurrentWorkloadReport
    def initialize(work_streams: Types::WorkStreamType.values, business_day_limit: 9)
      @work_streams = work_streams
      @business_day_limit = business_day_limit
    end

    attr_reader :work_streams

    def rows
      business_days.map do |business_day|
        CurrentWorkloadReportRow.new business_day: business_day,
                                     total_received: received_counts.fetch(business_day, 0),
                                     total_open: open_counts.fetch(business_day, 0)
      end
    end

    private

    def business_days
      Array.new(@business_day_limit + 1) do |age_in_business_days|
        BusinessDay.new(age_in_business_days:).date
      end
    end

    def scope
      Review.where(work_stream: work_streams, business_day: (business_days.last..business_days.first))
    end

    def received_counts
      @received_counts ||= received_apps_by_business_day.count
    end

    def received_apps_by_business_day
      scope.group(:business_day)
    end

    def open_counts
      @open_counts ||= open_apps_by_business_day.count
    end

    def open_apps_by_business_day
      scope.where(state: 'open').group(:business_day)
    end
  end
end
