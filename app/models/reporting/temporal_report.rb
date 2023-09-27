module Reporting
  class TemporalReport
    include ActiveModel::Model

    attr_reader :date, :report_type

    def initialize(date:, report_type:)
      @date = date
      @report_type = Types::TemporalReportType[report_type]
    end

    def to_param
      date.strftime(self.class::PARAM_FORMAT)
    end

    def interval
      self.class::INTERVAL
    end

    def period_name
      date.strftime(self.class::PERIOD_NAME_FORMAT)
    end

    def title
      report_text(:title, period_name:)
    end

    def next_report
      self.class.new(report_type: report_type, date: self.class.next_date(date))
    end

    def previous_report
      self.class.new(report_type: report_type, date: self.class.previous_date(date))
    end

    def rows
      @rows ||= read_model_klass.new(stream_name:).rows
    end

    # returns true if the report includes the current day
    def current?
      (period_starts_on..period_ends_on).cover? self.class._current_date
    end

    # :nocov:
    def period_text
      raise 'Implement in subclass.'
    end
    # :nocov:

    def stream_name
      date.strftime(CaseworkerReports::Configuration::STREAM_NAME_FORMATS.fetch(interval))
    end

    private

    def read_model_klass
      Reporting.const_get(Types::TemporalReportType[report_type].camelize)
    end

    def report_text(key, options = {})
      I18n.t(key, scope: i18n_scope, **options)
    end

    def i18n_scope
      self.class.name.underscore.split('/') << report_type
    end

    class << self
      # :nocov:
      def next_date(_date)
        raise 'Implement in subclass.'
      end

      def previous_date(_date)
        raise 'Implement in subclass.'
      end
      # :nocov:

      def from_param(report_type:, period:)
        date = Date.strptime(period, self::PARAM_FORMAT)
        new(report_type:, date:)
      rescue Date::Error
        raise Reporting::ReportNotFound
      end

      def klass_for_interval(interval)
        klass_name = "#{Types::TemporalInterval[interval]}_report".camelize
        Reporting.const_get(klass_name)
      rescue Dry::Types::ConstraintError
        raise Reporting::ReportNotFound
      end

      def latest_complete_report_date
        previous_date(_current_date)
      end

      def _current_date
        Time.current.in_time_zone('London').to_date
      end
    end
  end
end
