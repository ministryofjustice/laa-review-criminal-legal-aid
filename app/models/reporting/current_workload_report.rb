module Reporting
  class CurrentWorkloadReport
    def initialize(work_streams: Types::WorkStreamType.values, business_day_limit: 9)
      @work_streams = work_streams
      @business_day_limit = business_day_limit
    end

    attr_reader :work_streams

    def rows
      @rows ||= business_days.map do |business_day|
        CurrentWorkloadReportRow.new(
          business_day: business_day,
          total_received: received_counts.fetch(business_day.date, 0),
          total_open: open_counts.fetch(business_day.date, 0)
        )
      end
    end

    private

    def business_days
      @business_days ||= BusinessDay.list_backwards(
        age_limit: @business_day_limit
      )
    end

    def scope
      Review.where(
        work_stream: work_streams.map(&:to_s),
        business_day: (oldest_business_day_date..youngest_business_day_date)
      )
    end

    def oldest_business_day_date
      business_days.last.date
    end

    def youngest_business_day_date
      business_days.first.date
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
