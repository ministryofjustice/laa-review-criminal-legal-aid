module Reporting
  class WeeklyReportsController < Reporting::BaseController
    before_action :set_report_type
    before_action :require_report_access!

    def show
      @report = Reporting::WeeklyReport.from_param(
        report_type: @report_type, epoch: params[:epoch]
      )
    end
  end
end
