module Reporting
  class CaseworkerReport
    def initialize(dataset:)
      @dataset = dataset
    end

    def rows(sorting: sorting_klass.new_or_default)
      sorted_rows = dataset.values.sort_by do |r|
        v = r.public_send(sorting.sort_by)
        v.respond_to?(:upcase) ? v.upcase : v
      end

      return sorted_rows unless sorting.sort_direction == 'descending'

      sorted_rows.reverse
    end

    def sorting_klass
      CaseworkerReportSorting
    end

    private

    attr_reader :dataset

    class << self
      def for_time_period(time_period:)
        stream_name = CaseworkerReports.stream_name(
          date: time_period.starts_on,
          interval: time_period.interval
        )

        projection = CaseworkerReports::Projection.new(stream_name:)
        new(dataset: projection.dataset)
      end
    end
  end
end
