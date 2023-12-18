module Reporting
  class WorkloadReport
    AGE_LIMIT = 9

    # Builds a Workload Report from "observed_at" until "age_limit" business days
    # ago.
    def initialize(observed_at: Time.current, work_streams: Types::WorkStreamType.values)
      @work_streams = work_streams
      @observed_at = observed_at
    end

    def rows
      @rows ||= @work_streams.map do |work_stream|
        work_stream_dataset = raw_dataset.map { |rd| rd.fetch(work_stream) }
        WorkloadReportRow.new(work_stream: work_stream, dataset: work_stream_dataset)
      end
    end

    attr_reader :observed_at

    def raw_dataset
      @raw_dataset ||= business_days.map do |business_day|
        ReceivedOnReports::Projection.for_date(business_day.date, observed_at:).dataset
      end
    end

    def business_days
      @business_days ||= BusinessDay.list_backwards(
        day_zero: observed_at, age_limit: AGE_LIMIT
      )
    end
  end
end
