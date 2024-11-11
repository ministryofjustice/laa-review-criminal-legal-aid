module Reporting
  class WorkloadReportRow
    attr_reader :work_stream, :application_type

    def initialize(work_stream:, application_type:, dataset:)
      @work_stream = work_stream
      @dataset = dataset
      @application_type = application_type
    end

    def received_this_business_day
      @dataset.first.total_received
    end

    def backlogs
      @dataset.map(&:total_open)
    end

    def closed_this_business_day
      @dataset.sum(&:closed_on_observed_business_day)
    end

    Array.new(Reporting::WorkloadReport::AGE_LIMIT + 1) do |i|
      define_method(:"day#{i}") { backlogs[i] }
    end

    def day0_to_last_day
      backlogs.sum
    end
  end
end
