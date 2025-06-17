module Reporting
  class CaseworkerReport
    def initialize(dataset:, sorting: {})
      @dataset = dataset
      @sorting = CaseworkerReportSorting.new_or_default(sorting)
    end

    attr_reader :sorting

    def rows
      sort_data(dataset.basic_projection.values)
    end

    def csv(*) # rubocop:disable Metrics/AbcSize
      data = sort_data(dataset.work_queue_projection.values.map(&:values).flatten)
      CSV.generate do |csv|
        csv << ['user', 'work_queue', *CaseworkerReports::Row::COUNTERS, 'total_assigned_to_user',
                'total_unassigned_from_user', 'total_closed_by_user']
        data.each do |row|
          csv << [row.user_name, row.work_queue, *CaseworkerReports::Row::COUNTERS.map do |counter|
            row.send(counter)
          end, row.total_assigned_to_user, row.total_unassigned_from_user, row.total_closed_by_user]
        end
      end
    end

    private

    attr_reader :dataset

    class << self
      def for_time_period(time_period:, sorting: {}, **)
        stream_name = CaseworkerReports.stream_name(
          date: time_period.starts_on,
          interval: time_period.interval
        )

        dataset = CaseworkerReports::EventDataset.new(stream_name:)
        new(dataset:, sorting:)
      end
    end

    def sort_data(data)
      sorted = data.sort_by do |r|
        v = r.public_send(sorting.sort_by)
        v = v.upcase if v.respond_to?(:upcase)
        v.nil? ? -1 : v
      end

      return sorted unless sorting.sort_direction == 'descending'

      sorted.reverse
    end
  end
end
