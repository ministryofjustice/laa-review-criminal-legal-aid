module Reporting
  class TemporalReportsController < Reporting::BaseController
    before_action :set_report_type
    before_action :set_interval
    before_action :require_report_access!

    def show
      @report = report_klass.from_param(
        report_type: @report_type, period: params[:period]
      )
    end

    private

    def set_report_type
      @report_type = params.require(:report_type).presence_in(*Types::TemporalReportType)
    end

    def set_interval
      @interval = params.require(:interval).presence_in(*Types::TemporalInterval)
    end

    def report_klass
      Reporting::TemporalReport.klass_for_interval(@interval)
    end
  end
end
