module Reporting
  class CaseworkerReport
    def initialize(dataset:, sorting: {})
      @dataset = dataset
      @sorting = CaseworkerReportSorting.new_or_default(sorting)
    end

    attr_reader :sorting

    def rows
      sorted_rows = dataset.values.sort_by do |r|
        v = r.public_send(sorting.sort_by)
        v = v.upcase if v.respond_to?(:upcase)
        v.nil? ? -1 : v
      end

      return sorted_rows unless sorting.sort_direction == 'descending'

      sorted_rows.reverse
    end

    private

    attr_reader :dataset

    class << self
      def for_time_period(time_period:, sorting: {}, **)
        stream_name = CaseworkerReports.stream_name(
          date: time_period.starts_on,
          interval: time_period.interval
        )

        projection = CaseworkerReports::Projection.new(stream_name:)
        new(dataset: projection.dataset, sorting: sorting)
      end
    end
  end
end
