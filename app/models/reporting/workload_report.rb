module Reporting
  class WorkloadReport
    include Reportable

    def initialize(number_of_days: 4, day_zero: Time.zone.now.to_date)
      @number_of_days = number_of_days
      @day_zero = day_zero
    end

    def table
      Table.new(
        {
          days_passed:,
          received_applications_by_age:,
          open_applications_by_age:
        }
      )
    end

    private

    attr_reader :number_of_days, :day_zero

    def open_applications_by_age
      reports.map { |report| Cell.new(report.total_open, numeric: true) }
    end

    def received_applications_by_age
      reports.map { |report| Cell.new(report.total_received, numeric: true) }
    end

    #
    # Days passed header column for table.
    # Returns an array of header cells with contents:
    #
    # 0 days
    # 1 day
    # 2 days
    # 3 or more days
    #
    #
    def days_passed
      # All bar last header
      row_headers = Array.new(number_of_days - 1) do |day|
        I18n.t('values.days_passed', count: day)
      end

      # Add the last header.
      row_headers << I18n.t('values.days_passed.last', count: number_of_days - 1)

      row_headers.map { |text| Cell.new(text, header: true, numeric: false) }
    end

    def business_days
      @business_days ||= Array.new(number_of_days) do |age_in_business_days|
        BusinessDay.new(
          age_in_business_days:,
          day_zero:
        )
      end
    end

    def reports
      @reports ||= business_days.map do |business_day|
        if business_day == business_days.last
          last_day_or_more_report
        else
          Reporting::ReceivedOnReport.find_or_initialize_by(
            business_day: business_day.date
          )
        end
      end
    end

    #
    # The last row of the report differs from the preceding rows in that it
    # includes the counts for all earlier dates.
    #
    def last_day_or_more_report
      scope = Reporting::ReceivedOnReport.where('business_day <= ?', business_days.last.date)
      total_received = scope.sum(:total_received)
      total_closed = scope.sum(:total_closed)

      Reporting::ReceivedOnReport.new(total_received:, total_closed:)
    end
  end
end
