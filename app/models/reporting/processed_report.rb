module Reporting
  class ProcessedReport
    include Reportable

    def initialize(day_zero: Time.zone.now.to_date)
      @day_zero = day_zero
    end

    def table
      Table.new(
        {
          processed_on:,
          applications_closed:
        }
      )
    end

    private

    attr_reader :day_zero

    def applications_closed
      Array.new(3) do |days_ago|
        date = day_zero - days_ago
        Cell.new(closing_events.between(date...date.tomorrow).count)
      end
    end

    def processed_on
      %i[today yesterday day_before_yesterday].map do |key|
        Cell.new(I18n.t(key, scope: :values), header: true)
      end
    end

    def closing_events
      closing_event_types = [Reviewing::SentBack, Reviewing::Completed]

      Rails.configuration.event_store.read.of_type(closing_event_types).backward
    end
  end
end
