class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_dashboard_access!, only: [:index]
  before_action :require_report_access!, only: [:show]
  before_action :set_security_headers

  def index; end

  def show
    case params[:id]
    when /workload_report/
      @report = Reporting::WorkloadReport.new
    when /processed_report/
      @report = Reporting::ProcessedReport.new
    when /caseworker_report/
      @report = Reporting::CaseworkerReport.new
    else
      raise ActiveRecord::RecordNotFound, 'Report not found'
    end
  end

  private

  def require_dashboard_access!
    return if current_user.can_access_reporting_dashboard?

    raise ForbiddenError, 'Must be a reporting user'
  end

  def require_report_access!
    raise ForbiddenError, 'Report access denied' unless current_user.reports.include?(params[:id])
  end
end
