module Reporting
  class UserReportsController < Reporting::BaseController
    before_action :set_report_type, except: :index

    before_action :require_dashboard_access!, only: [:index]
    before_action :require_report_access!, only: [:show]

    def index
      @latest_temporal_reports = latest_temporal_reports
      @snapshot_report_types = snapshot_report_types
    end

    def show
      @report = Reporting.const_get(Types::Report[@report_type].camelize).new
    end

    private

    def set_report_type
      @report_type = params.require(:report_type).presence_in(*Types::Report)
    end

    # Returns a list of the latest complete temporal reports for a given user
    # NOTE: this code is temporary and used here to provide a list of temporal
    # reports for protyping purposes only.
    def latest_temporal_reports
      Types::TemporalInterval.values.flat_map do |interval|
        klass = Reporting::TemporalReport.klass_for_interval(interval)
        date = klass.latest_complete_report_date

        temporal_report_types.map do |report_type|
          klass.new(report_type:, date:)
        end
      end
    end

    def temporal_report_types
      current_user.reports & Types::TemporalReportType.values
    end

    def snapshot_report_types
      current_user.reports & Types::SnapshotReportType.values
    end
  end
end
