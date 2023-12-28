module Reporting
  class TemporalReportsController < Reporting::BaseController
    before_action :set_report_type
    before_action :set_interval
    before_action :require_report_downloader!, only: [:download]
    before_action :require_report_access!
    before_action :set_report, only: [:show, :download]

    def show
      @sorting = @report.sorting
    end

    def now
      @report = Reporting::TemporalReport.current(
        interval: @interval,
        report_type: @report_type,
        sorting: permitted_params[:sorting],
        page: permitted_params[:page]
      )

      @sorting = @report.sorting

      render :show
    end

    def download
      file = permitted_params[:file]
      send_data(
        @report.source_csv(file:),
        file_name: '@report.id',
        filename: @report.source_csv_filename(file:),
        type: 'text/csv; charset=utf-8; header=present'
      )
    end

    private

    def permitted_params
      params.permit(
        :report_type,
        :interval,
        :period,
        :page,
        :file,
        sorting: [:sort_by, :sort_direction]
      )
    end

    def set_report_type
      @report_type = permitted_params.require(:report_type).presence_in(*Types::TemporalReportType)
    end

    def set_report
      @report = Reporting::TemporalReport.from_param(
        report_type: @report_type,
        period: permitted_params[:period],
        interval: @interval,
        sorting: permitted_params[:sorting],
        page: permitted_params[:page]
      )
    end

    def set_interval
      @intervals = Types::TemporalInterval
      @interval = permitted_params.require(:interval).presence_in(*@intervals)
    end
  end
end
