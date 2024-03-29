module Reporting
  class ProcessedReport
    attr_reader :number_of_rows, :work_streams

    def initialize(work_streams: Types::WorkStreamType.values, number_of_rows: 3)
      @work_streams = work_streams
      @number_of_rows = number_of_rows
    end

    def rows
      days.map do |day|
        { date: day, total_processed: counts.fetch(day, 0) }
      end
    end

    private

    def days
      Array.new(@number_of_rows) do |days_ago|
        today - days_ago
      end
    end

    def today
      @today ||= Time.zone.now.in_time_zone('London').to_date
    end

    def scope
      Review.where(
        work_stream: work_streams.map(&:to_s),
        reviewed_on: (days.last..days.first)
      )
    end

    def counts
      @counts ||= scope.group(:reviewed_on).count
    end
  end
end
