module Reporting
  class WeeklyReport
    PARAM_FORMAT = '%G-%V'.freeze

    include Reporting::Reportable

    def initialize(date:, report_type:)
      @date = date
      @report_type = Types::WeeklyReportType[report_type]
    end

    def epoch_name
      date.strftime('Week %V, %G')
    end

    def start_on
      date.beginning_of_week
    end

    def end_on
      date.end_of_week
    end

    def next_report
      self.class.new(report_type: report_type, date: (date + 7))
    end

    def previous_report
      self.class.new(report_type: report_type, date: (date - 7))
    end

    private

    def stream_name
      date.strftime CaseworkerReports::STREAM_NAME_FORMATS.fetch('weekly')
    end

    class << self
      def _latest_date
        _current_date - 7
      end
    end
  end
end
