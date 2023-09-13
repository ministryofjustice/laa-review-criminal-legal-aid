module Reporting
  class MonthlyReport
    include Reporting::Reportable

    PARAM_FORMAT = '%Y-%B'.freeze

    def initialize(date:, report_type:)
      @date = date
      @report_type = Types::Report[report_type]
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
      def from_param(report_type:, month:)
        date = Date.strptime(month, PARAM_FORMAT)
        new(report_type:, date:)
      end

      def latest(report_type:)
        current_date = Time.current.in_time_zone('London').to_date
        date = current_date << 1
        new(report_type:, date:)
      end
    end
  end
end
