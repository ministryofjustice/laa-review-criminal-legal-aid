module Reporting
  class WorkloadReport
    include Reportable

    def initialize(number_of_days: 4)
      @number_of_days = number_of_days
    end

    def table
      Table.new(
        {
          days_passed:,
          open_applications_by_age:,
          closed_applications_by_age:
        }
      )
    end

    private

    attr_reader :number_of_days

    #
    # Days passed header column for table.
    # Returns an array of header cells with contents:
    #
    # 0 days
    # 1 day
    # 2 days
    # 3 or more days
    #
    def days_passed
      # All bar last header
      row_headers = Array.new(number_of_days - 1) do |day|
        I18n.t('values.days_passed', count: day)
      end

      # Add the last header.
      row_headers << I18n.t('values.days_passed.last', count: number_of_days - 1)

      row_headers.map { |text| Cell.new(text, header: true) }
    end

    def open_applications_by_age
      filter = ApplicationSearchFilter.new(application_status: 'open')
      counts = DailyCount.new(filter:, number_of_days:).counts
      counts.map { |count| Cell.new(count) }
    end

    def closed_applications_by_age
      filter = ApplicationSearchFilter.new(application_status: 'sent_back')
      counts = DailyCount.new(filter:, number_of_days:).counts
      counts.map { |count| Cell.new(count) }
    end
  end
end
