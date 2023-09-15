module Reporting
  class WeeklyReport
    include Reporting::Reportable

    PARAM_FORMAT = '%G-%V'.freeze

    def initialize(date:, report_type:)
      @date = date
      @report_type = Types::WeeklyReportType[report_type]
    end

    attr_reader :date, :report_type

    def to_param
      date.strftime(PARAM_FORMAT)
    end

    def week_name
      date.strftime('Week %V, %G')
    end

    def title
      report_text(:title, week_name:)
    end

    def start_on
      date.beginning_of_week
    end

    def end_on
      date.end_of_week
    end

    private

    def stream_name
      date.strftime CaseworkerReports::STREAM_NAME_FORMATS.fetch('weekly')
    end

    class << self
      def supported_report_types
        Types::WeeklyReportType.values
      end

      def from_param(report_type:, week:)
        date = Date.strptime(week, PARAM_FORMAT)
        new(report_type:, date:)
      end

      def _latest_date
        _current_date - 7
      end
    end
  end
end
