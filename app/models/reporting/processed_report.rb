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

    def counts
      @counts ||= Review.where(reviewed_on: (days.last..days.first)).group(:reviewed_on).count
    end

    def processed_on
      %i[today yesterday day_before_yesterday].map do |key|
        Cell.new(I18n.t(key, scope: :values), header: true, numeric: false)
      end
    end
  end
end
