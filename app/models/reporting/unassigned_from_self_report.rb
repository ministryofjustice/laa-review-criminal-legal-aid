module Reporting
  class UnassignedFromSelfReport
    def initialize(dataset:)
      @dataset = dataset
    end

    def rows
      dataset.values
    end

    class << self
      def for_time_period(time_period:, **)
        stream_name = CaseworkerReports.stream_name(
          date: time_period.starts_on,
          interval: time_period.interval
        )

        dataset = CaseworkerReports::UnassignedFromSelfProjection.new(stream_name:).dataset
        new(dataset:)
      end
    end

    private

    attr_reader :dataset
  end
end
