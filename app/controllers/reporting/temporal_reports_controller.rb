module Reporting
  class TemporalReportsController < Reporting::BaseController
    before_action :set_report_type
    before_action :set_interval
    before_action :require_report_access!

    def show
      @report = Reporting::TemporalReport.from_param(
        report_type: @report_type,
        period: params[:period],
        interval: @interval
      )

      @sorting = @report.sorting_klass.new(permitted_params[:sorting])
    end

    def now
      @report = Reporting::TemporalReport.current(
        interval: @interval, report_type: @report_type
      )

      @sorting = @report.sorting_klass.new(permitted_params[:sorting])

      render :show
    end

    private

    def permitted_params
      params.permit(
        :report_type,
        :interval,
        sorting: [:sort_by, :sort_direction]
      )
    end

    def set_report_type
      @report_type = permitted_params.require(:report_type).presence_in(*Types::TemporalReportType)
    end

    def set_interval
      @intervals = Types::TemporalInterval
      @interval = permitted_params.require(:interval).presence_in(*@intervals)
    end
  end
end
