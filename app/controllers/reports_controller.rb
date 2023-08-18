class ReportsController < ServiceController
  def index
    raise ActiveRecord::RecordNotFound, 'Reports not found' unless current_user.can_access_reporting_dashboard?
  end

  def show
    raise ActiveRecord::RecordNotFound, 'Report not found' unless current_user.reports.include?(params[:id])

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
end
