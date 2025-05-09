module Reporting
  class GeneratedReportsController < Reporting::BaseController
    before_action :require_download_access!, only: [:download]
    before_action :generated_report
    before_action :report_type
    before_action :require_report_access!

    def download
      report = generated_report.report
      send_data report.download,
                filename: report.filename.to_s,
                content_type: report.content_type,
                disposition: 'attachment'
    end

    private

    def generated_report
      @generated_report ||= GeneratedReport.find(params.require(:id))
    end

    def report_type
      @report_type ||= generated_report.report_type
    end
  end
end
