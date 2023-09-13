module Reporting
  class MonthlyReportsController < Reporting::BaseController
    before_action :set_report_type
    before_action :require_report_access!

    def show
      @report = Reporting::MonthlyReport.from_param(
        report_type: @report_type, month: params[:month]
      )
    end
  end
end
