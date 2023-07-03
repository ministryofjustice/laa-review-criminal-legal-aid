module Reporting
  class WorkloadReport
    include Reportable

    # Builds a Workload Report table with 'n' number of rows. The first row corresponds
    # to applications that were received zero business days ago. The second row
    # applications received one business day ago, and so on, until the last row, which
    # includes a count up to the specified 'last_row_limit_in_days'.
    def initialize(number_of_rows: 4, day_zero: Time.current, last_row_limit_in_days: 9)
      @number_of_rows = number_of_rows
      @day_zero = day_zero.in_time_zone('London').to_date
      @last_row_limit_in_days = last_row_limit_in_days
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

    attr_reader :number_of_rows, :day_zero, :last_row_limit_in_days

    def open_applications_by_age
      reports.map { |report| Cell.new(report.total_open, numeric: true) }
    end

    def received_applications_by_age
      reports.map { |report| Cell.new(report.total_received, numeric: true) }
    end

    #
    # Business days since application were received header column for table.
    # Returns an array of header cells with contents:
    #
    # 0 days
    # 1 day
    # 2 days
    # between 3(#number_of_rows) and (#last_row_limit_in_days)
    #
    #
    def days_passed
      # All bar last row header
      row_headers = Array.new(number_of_rows - 1) do |day|
        I18n.t('values.days_passed', count: day)
      end

      # Add the last row header.
      row_headers << last_row_header_text

      row_headers.map { |text| Cell.new(text, header: true, numeric: false) }
    end

    def business_days
      @business_days ||= Array.new(number_of_rows) do |age_in_business_days|
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

    # The date of the youngest business day not included in the last
    # row counts -- all applications in the last row must have a business
    # date younger than this date.
    def last_row_cut_off_date
      @last_row_cut_off_date ||= BusinessDay.new(
        age_in_business_days: last_row_limit_in_days + 1,
        day_zero: day_zero
      ).date
    end

    def last_row_header_text
      I18n.t(
        'values.days_passed.last',
        count: number_of_rows - 1,
        limit: last_row_limit_in_days
      )
    end

    #
    # The last row of the report differs from the preceding rows in that it
    # includes the counts for the previous business days up to and including the
    # #last_row_limit_in_days business day period.
    #
    def last_day_or_more_report
      scope = Reporting::ReceivedOnReport.where(
        'business_day > ? AND business_day <= ? ',
        last_row_cut_off_date,
        business_days.last.date
      )

      total_received = scope.sum(:total_received)
      total_closed = scope.sum(:total_closed)

      Reporting::ReceivedOnReport.new(total_received:, total_closed:)
    end
  end
end
