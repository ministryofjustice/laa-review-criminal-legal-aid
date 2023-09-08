module Reporting
  class UserReportsController < Reporting::BaseController
    before_action :set_report_type, except: :index
    before_action :set_report, except: :index

    before_action :require_dashboard_access!, only: [:index]
    before_action :require_report_access!, only: [:show]

    def index; end

    def show; end

    private

    def set_report
      @report = report_type_report_mapping[@report_type]
    end

    def report_type_report_mapping
      ActiveSupport::HashWithIndifferentAccess.new(
        workload_report: Reporting::WorkloadReport.new,
        processed_report: Reporting::ProcessedReport.new,
        caseworker_report: Reporting::CaseworkerReport.new
      )
    end
  end
end
