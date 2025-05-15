module Reporting
  class TemporalReportsController < Reporting::BaseController
    before_action :set_report_type
    before_action :set_interval
    before_action :require_download_access!, only: [:download]
    before_action :require_report_access!
    before_action :set_report, only: [:show, :download]

    def show
      @sorting = @report.sorting
      @generated_report = GeneratedReport.by_temporal_report(@report).first
    end

    def download
      file = permitted_params[:file] || 1
      send_data(
        @report.csv(file:),
        file_name: '@report.id',
        filename: @report.csv_filename(file:),
        type: 'text/csv; charset=utf-8; header=present'
      )
    end

    def latest_complete
      report = Reporting::TemporalReport.current(
        interval: @interval,
        report_type: @report_type,
        sorting: permitted_params[:sorting]
      ).previous_report

      redirect_to reporting_temporal_report_path(report.to_param)
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
