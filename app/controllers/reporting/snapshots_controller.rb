module Reporting
  class SnapshotsController < Reporting::BaseController
    before_action :set_report_type
    before_action :require_report_access!

    def show
      @report = Reporting::Snapshot.from_param(
        report_type: @report_type,
        work_streams: work_streams,
        date: params[:date],
        time: params[:time]
      )
    end

    def now
      @report = Reporting::Snapshot.new(
        report_type: @report_type, work_streams: work_streams
      )

      render :show
    end

    private

    def work_streams
      current_user.work_streams
    end

    def set_report_type
      @report_type = params.require(:report_type).presence_in(*Types::SnapshotReportType)
    end
  end
end
