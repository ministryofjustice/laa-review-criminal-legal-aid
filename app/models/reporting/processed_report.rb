module Reporting
  class ProcessedReport
    def initialize(work_streams: Types::WorkStreamType.values, number_of_rows: 3)
      @work_streams = work_streams
      @number_of_rows = number_of_rows
    end

    attr_reader :work_streams

    def rows
      days.map do |day|
        { date: day, total_processed: counts.fetch(day, 0) }
      end
    end

    private

    attr_reader :number_of_rows

    def days
      Array.new(@number_of_rows) do |days_ago|
        today - days_ago
      end
    end

    def today
      @today ||= Time.zone.now.in_time_zone('London').to_date
    end

    def scope
      Review.where(work_stream: work_streams, reviewed_on: (days.last..days.first))
    end

    def counts
      @counts ||= scope.group(:reviewed_on).count
    end
  end
end
