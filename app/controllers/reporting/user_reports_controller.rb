module Reporting
  class UserReportsController < Reporting::BaseController
    before_action :set_report_type, except: :index

    before_action :require_dashboard_access!, only: [:index]
    before_action :require_report_access!, only: [:show]

    def index
      @monthly_reports = Reporting::MonthlyReport.latest(report_types: current_user.reports)
      @weekly_reports = Reporting::WeeklyReport.latest(report_types: current_user.reports)
    end

    def show
      @report = Reporting.const_get(@report_type.camelize).new
    end
  end
end
