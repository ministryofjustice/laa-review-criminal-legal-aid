module Reporting
  class ProcessedReport
    include Reportable

    def initialize(day_zero: Time.current)
      @day_zero = day_zero.in_time_zone('London').to_date
    end

    def table
      Table.new({ processed_on:, applications_closed: }, numeric_column_keys: [])
    end

    private

    attr_reader :day_zero

    def applications_closed
      Array.new(3) do |days_ago|
        date_from = day_zero - days_ago
        date_to = date_from.tomorrow
        Cell.new(closing_events.between(date_from...date_to).count, numeric: false)
      end
    end

    def processed_on
      %i[today yesterday day_before_yesterday].map do |key|
        Cell.new(I18n.t(key, scope: :values), header: true, numeric: false)
      end
    end

    def closing_events
      closing_event_types = [Reviewing::SentBack, Reviewing::Completed]

      Rails.configuration.event_store.read.of_type(closing_event_types).backward
    end
  end
end
