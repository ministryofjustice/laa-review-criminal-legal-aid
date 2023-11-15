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

      @sorting = report_sorting
    end

    def now
      @report = Reporting::TemporalReport.current(
        interval: @interval, report_type: @report_type
      )

      @sorting = report_sorting

      render :show
    end

    private

    def permitted_params
      params.permit(
        :report_type,
        :interval,
        :period,
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

    def report_sorting
      @report.sorting_klass.new_or_default(
        permitted_params[:sorting]
      )
    end
  end
end
