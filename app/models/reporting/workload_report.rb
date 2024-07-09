module Reporting
  class WorkloadReport
    AGE_LIMIT = 9

    # Builds a Workload Report from "observed_at" until "age_limit" business days
    # ago.
    def initialize(observed_at: Time.current, work_streams: WorkStream.all)
      @work_streams = work_streams
      @observed_at = observed_at
    end

    def rows
      @rows ||= @work_streams.map do |work_stream|
        application_types.map do |application_type|
          dataset = raw_dataset.map { |rd| rd.dig(work_stream.to_s, application_type) }
          WorkloadReportRow.new(work_stream:, dataset:, application_type:)
        end
      end
    end

    def business_days
      @business_days ||= BusinessDay.list_backwards(
        day_zero: observed_at, age_limit: AGE_LIMIT
      )
    end

    private

    attr_reader :observed_at

    def application_types
      [
        Types::ApplicationType['initial'],
        Types::ApplicationType['post_submission_evidence'],
        Types::ApplicationType['change_in_financial_circumstances']
      ]
    end

    def raw_dataset
      @raw_dataset ||= business_days.map do |business_day|
        ReceivedOnReports::Projection.for_date(business_day.date, observed_at:).dataset
      end
    end
  end
end
