class ReportsController < ServiceController
  def show
    case params[:id]
    when /workload_report/
      @report = Reporting::WorkloadReport.new
    when /processed_report/
      @report = Reporting::ProcessedReport.new
    else
      redirect_to not_found_path
    end
  end
end
