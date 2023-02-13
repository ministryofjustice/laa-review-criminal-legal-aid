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

    #
    # TODO: This can be calculated from review data
    # as soon as the Review read_model is available.
    #
    def applications_closed
      dates.map do |date|
        filter = ApplicationSearchFilter.new(
          submitted_after: date,
          submitted_before: date.next_day,
          application_status: 'sent_back'
        )

        Cell.new(ApplicationSearch.new(filter:, pagination:).total)
      end
    end

    def dates
      [
        day_zero,
        day_zero.prev_day,
        day_zero.prev_day.prev_day
      ]
    end

    def processed_on
      %i[today yesterday day_before_yesterday].map do |key|
        Cell.new(I18n.t(key, scope: :values), header: true)
      end
    end

    def pagination
      @pagination ||= Pagination.new(limit_value: 1)
    end
  end
end
