module Reporting
  class WorkloadReportRow
    attr_reader :work_stream

    def initialize(work_stream:, dataset:)
      @work_stream = work_stream
      @dataset = dataset
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
      define_method("day#{i}") { backlogs[i] }
    end

    def day4_to_last_day
      day0_to_last_day - backlogs.first(4).sum
    end

    def day0_to_last_day
      backlogs.sum
    end
  end
end
