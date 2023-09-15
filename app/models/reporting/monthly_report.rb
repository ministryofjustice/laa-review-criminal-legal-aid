module Reporting
  class MonthlyReport
    PARAM_FORMAT = '%Y-%B'.freeze

    include Reporting::Reportable

    def initialize(date:, report_type:)
      @date = date
      @report_type = Types::MonthlyReportType[report_type]
    end

    def epoch_name
      date.strftime('%B, %Y')
    end

    def start_on
      date.beginning_of_month
    end

    def end_on
      date.end_of_month
    end

    def next_report
      self.class.new(report_type: report_type, date: date >> 1)
    end

    def previous_report
      self.class.new(report_type: report_type, date: date << 1)
    end

    private

    def stream_name
      date.strftime CaseworkerReports::STREAM_NAME_FORMATS.fetch('monthly')
    end

    class << self
      def _latest_date
        _current_date << 1
      end
    end
  end
end
