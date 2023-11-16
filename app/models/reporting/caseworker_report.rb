module Reporting
  class CaseworkerReport
    def initialize(dataset:)
      @dataset = dataset
    end

    def rows(sorting: CaseworkerReportSorting.default)
      sorted_rows = dataset.values.sort_by do |r|
        v = r.public_send(sorting.sort_by)
        v.respond_to?(:upcase) ? v.upcase : v
      end

      return sorted_rows unless sorting.sort_direction == 'descending'

      sorted_rows.reverse
    end

    private

    attr_reader :dataset

    class << self
      def for_temporal_period(date:, interval:)
        stream_name = CaseworkerReports.stream_name(date:, interval:)

        projection = CaseworkerReports::Projection.new(stream_name:)
        new(dataset: projection.dataset)
      end
    end
  end
end
