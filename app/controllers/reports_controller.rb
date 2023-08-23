class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_reporting_user!
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

  def require_reporting_user!
    return if current_user.reporting_user?

    raise ForbiddenError, 'Must be a reporting user'
  end
end
