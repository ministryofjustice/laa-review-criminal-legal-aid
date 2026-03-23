module Reporting
  class UserTemporalReportsController < Reporting::TemporalReportsController
    include ApplicationSearchable

    before_action :set_user_id

    def show
      @user = User.find(@user_id)
      row = @report.rows.find { |r| r[:user_id] == @user.id }
      @assignment_ids = row ? row[:assignment_ids] : []

      filter_ids = @assignment_ids.presence || [SecureRandom.uuid]
      set_search(default_filter: { application_id_in: filter_ids })
    end

    def latest_complete
      report = Reporting::TemporalReport.current(
        interval: @interval,
        report_type: @report_type,
        **extra_report_params
      ).previous_report

      redirect_to reporting_user_temporal_report_path(report.to_param)
    end

    private

    def require_report_access!
      return if current_user.reports.include?(Types::UserTemporalReportType['unassigned_from_self_report'])

      raise ForbiddenError, 'Cannot access this report type'
    end

    def extra_report_params
      { user_id: @user_id }
    end

    def set_user_id
      @user_id = params[:user_id]
    end
  end
end
