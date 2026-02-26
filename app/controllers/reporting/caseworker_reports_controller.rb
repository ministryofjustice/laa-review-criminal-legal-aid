module Reporting
  class CaseworkerReportsController < Reporting::BaseController
    before_action :require_report_access!

    def show
      @user = User.find(params[:user_id])

      temporal_report = Reporting::TemporalReport.from_param(
        report_type: REPORT_TYPE,
        period: permitted_params[:period],
        interval: permitted_params.require(:interval).presence_in(*Types::TemporalInterval)
      )

      @row = temporal_report.rows.find { |r| r.user_id == @user.id }
    end

    REPORT_TYPE = Types::TemporalReportType['caseworker_report']

    private

    def permitted_params
      params.permit(:interval, :period, :user_id)
    end

    def require_report_access!
      @report_type = REPORT_TYPE

      return if current_user.reports.include?(@report_type)

      raise ForbiddenError, 'Cannot access this report type'
    end
  end
end
