module Reporting
  class MonthlyReport
    include Reporting::Reportable

    PARAM_FORMAT = '%Y-%B'.freeze

    def initialize(date:, report_type:)
      @date = date
      @report_type = Types::MonthlyReportType[report_type]
    end

    attr_reader :date, :report_type

    def to_param
      date.strftime(PARAM_FORMAT)
    end

    def month_name
      date.strftime('%B %Y')
    end

    def title
      report_text(:title, month_name:)
    end

    private

    def stream_name
      return nil unless report_type == 'caseworker_report'

      date.strftime CaseworkerReports::STREAM_NAME_FORMATS.fetch('monthly')
    end

    class << self
      def supported_report_types
        Types::MonthlyReportType.values
      end

      def from_param(report_type:, month:)
        date = Date.strptime(month, PARAM_FORMAT)
        new(report_type:, date:)
      end

      def _latest_date
        _current_date << 1
      end
    end
  end
end
