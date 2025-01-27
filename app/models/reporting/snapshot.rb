module Reporting
  class Snapshot
    include ActiveModel::Model

    attr_reader :observed_at, :report_type, :work_streams

    def initialize(report_type:, observed_at: Time.current, work_streams: [])
      @observed_at = observed_at.in_time_zone('London')
      @report_type = Types::SnapshotReportType[report_type]
      @work_streams = work_streams
    end

    def to_param
      {
        report_type: report_type,
        date: observed_at.strftime('%Y-%m-%d'),
        time: observed_at.strftime('%H:%M')
      }
    end

    def title
      report_text(:title, observed_at:)
    end

    def next_report
      self.class.new(report_type: report_type, observed_at: observed_at.tomorrow.end_of_day, work_streams: work_streams)
    end

    def previous_report
      self.class.new(report_type: report_type, observed_at: (observed_at - 1.day).end_of_day,
                     work_streams: work_streams)
    end

    def rows
      @rows ||= read_model_klass.new(observed_at:, work_streams:).rows
    end

    # returns true if the report includes the current day
    def current?
      observed_at.to_date == self.class._current_date
    end

    def observed_business_day
      BusinessDay.new(day_zero: observed_at)
    end

    def observed_business_period_text
      starts_on = observed_business_day.starts_on

      if observed_business_day == starts_on
        I18n.l(observed_at, format: 'midnight until %-l:%M%P')
      else
        starts_on.strftime('midnight %A to ') + I18n.l(observed_at, format: '%-l:%M%P %A')
      end
    end

    def observed_at_time
      I18n.l(observed_at, format: '%-l:%M%P')
    end

    private

    def read_model_klass
      Reporting.const_get(Types::SnapshotReportType[report_type].camelize)
    end

    def report_text(key, options = {})
      I18n.t(key, scope: i18n_scope, **options)
    end

    def i18n_scope
      self.class.name.underscore.split('/') << report_type
    end

    class << self
      def _current_date
        Time.current.in_time_zone('London').to_date
      end

      def from_param(report_type:, date:, time:, work_streams:)
        observed_at = ActiveSupport::TimeZone['London'].parse("#{date} #{time}")

        new(report_type:, observed_at:, work_streams:)
      rescue ArgumentError, Dry::Types::ConstraintError
        raise Reporting::ReportNotFound
      end
    end
  end
end
