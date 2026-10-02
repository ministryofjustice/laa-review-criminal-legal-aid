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
      @latest_temporal_reports = latest_temporal_reports
      @report = Reporting.const_get(Types::Report[@report_type].camelize).new(work_streams:)
    end

    private

    def set_report_type
      @report_type = params.require(:report_type).presence_in(*Types::Report)
    end

    def work_streams
      return current_user.work_streams if requested_work_streams.empty?

      requested_work_streams & current_user.work_streams
    end

    def requested_work_streams
      return [] unless params[:work_streams]

      params[:work_streams].map do |work_stream_param|
        WorkStream.from_param(work_stream_param)
      end
    end

    # Returns a list of the latest complete temporal reports for a given user
    # NOTE: this code is temporary and used here to provide a list of temporal
    # reports for prototyping purposes only.
    def latest_temporal_reports
      temporal_report_types.map do |report_type|
        interval = interval_for(report_type)
        Reporting::TemporalReport.current(report_type:, interval:).previous_report
      end
    end

    # Some report types (e.g. volumes_by_office_report, slipstream_audit_report)
    # are only ever produced monthly, regardless of the user's default
    # reporting interval.
    def interval_for(report_type)
      # rubocop:disable-next Performance/InefficientHashSearch
      return Types::TemporalInterval['monthly'] if Types::MonthlyOnlyReportType.values.include?(report_type)
      return Types::TemporalInterval['monthly'] if current_user.data_analyst? || current_user.auditor?

      Types::TemporalInterval['daily']
    end

    def temporal_report_types
      (current_user.reports & Types::TemporalReportType.values) - Types::UserTemporalReportType.values
    end

    def snapshot_report_types
      current_user.reports & Types::SnapshotReportType.values
    end
  end
end
