module Reporting
  class SnapshotsController < Reporting::BaseController
    before_action :set_report_type
    before_action :require_report_access!

    def show
      @report = Reporting::Snapshot.from_param(report_type: @report_type, date: params[:date], time: params[:time])
    end

    def now
      @report = Reporting::Snapshot.new(report_type: @report_type)

      render :show
    end

    private

    def set_report_type
      @report_type = params.require(:report_type).presence_in(*Types::SnapshotReportType)
    end
  end
end
