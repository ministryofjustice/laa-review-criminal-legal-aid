module Reporting
  class WorkloadReport
    def initialize
      @number_of_rows = 4
      @slug = 'workload_report'
    end

    def id
      @slug
    end

    attr_reader :number_of_rows, :to_param

    def headers
      table.keys.map do |header|
        I18n.t(header, scope: :table_headings)
      end
    end

    def rows
      table.values.transpose
    end

    private

    def table
      {
        days_passed:,
        open_applications_by_age:,
        closed_applications_by_age:
      }
    end

    def open_applications_by_age
      DailyCount.new(filter: ApplicationSearchFilter.new(application_status: 'open')).counts.map do |content|
        Cell.new(content)
      end
    end

    def closed_applications_by_age
      DailyCount.new(
        filter: ApplicationSearchFilter.new(application_status: 'sent_back')
      ).counts.map { |content| Cell.new(content) }
    end

    def days_passed
      Array.new(number_of_rows) do |index|
        last_row = (index + 1) == number_of_rows

        content = if last_row
                    I18n.t('values.days_passed.last', count: index)
                  else
                    I18n.t('values.days_passed', count: index)
                  end

        Cell.new(content, header: true)
      end
    end
  end
end
