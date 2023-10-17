module Reporting
  class TemporalReportsController < Reporting::BaseController
    before_action :set_report_type
    before_action :set_interval
    before_action :require_report_access!

    def show
      @report = Reporting::TemporalReport.from_param(
        report_type: @report_type, period: params[:period], interval: @interval
      )
    end

    def now
      @report = Reporting::TemporalReport.current(
        interval: @interval, report_type: @report_type
      )

      render :show
    end

    private

    def set_report_type
      @report_type = params.require(:report_type).presence_in(*Types::TemporalReportType)
    end

    def set_interval
      @intervals = Types::TemporalInterval
      @interval = params.require(:interval).presence_in(*@intervals)
    end
  end
end
