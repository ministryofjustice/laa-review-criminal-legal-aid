module Reporting
  class CaseworkerTemporalReportsController < Reporting::TemporalReportsController
    include ApplicationSearchable

    before_action :set_caseworker_id

    def show
      @user = User.find(@caseworker_id)
      row = @report.rows.find { |r| r[:user_id] == @user.id }
      @assignment_ids = row ? row[:assignment_ids] : []

      filter_ids = @assignment_ids.presence || [SecureRandom.uuid]
      set_search(default_filter: { application_id_in: filter_ids })
    end

    def latest_complete
      report = Reporting::TemporalReport.current(
        interval: @interval,
        report_type: @report_type
      ).previous_report

      redirect_to reporting_caseworker_temporal_report_path(
        report_type: @report_type,
        interval: @interval,
        period: report.period_as_param,
        user_id: params[:user_id]
      )
    end

    private

    def set_caseworker_id
      @caseworker_id = params[:user_id]
    end
  end
end
