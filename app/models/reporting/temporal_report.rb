module Reporting
  class TemporalReport
    include ActiveModel::Model

    attr_reader :time_period, :report_type

    def initialize(time_period:, report_type:)
      @time_period = time_period
      @report_type = Types::TemporalReportType[report_type]
    end

    def to_param
      {
        report_type: report_type,
        interval: time_period.interval,
        period: time_period.starts_on.strftime(self.class::PARAM_FORMAT)
      }
    end

    def id
      to_param.values.join('_')
    end

    def period_name
      time_period.starts_on.strftime(self.class::PERIOD_NAME_FORMAT)
    end

    def title
      report_text(:title, period_name:)
    end

    def next_report
      self.class.new(time_period: time_period.next, report_type: report_type)
    end

    def previous_report
      self.class.new(time_period: time_period.previous, report_type: report_type)
    end

    def rows(sorting: nil)
      @rows ||= read_model_klass.for_time_period(time_period:).rows(sorting:)
    end

    # returns true if the report includes the current day
    def current?
      time_period.range.cover? self.class._current_date
    end

    # :nocov:
    def period_text
      raise 'Implement in subclass.'
    end
    # :nocov:
    #

    def sorting_klass
      Reporting.const_get("#{report_type}_sorting".camelize)
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
      def from_param(report_type:, period:, interval:)
        klass = klass_for_interval(interval)
        date = Date.strptime(period, klass::PARAM_FORMAT)
        time_period = TimePeriod.new(interval:, date:)
        klass.new(report_type:, time_period:)
      rescue Date::Error
        raise Reporting::ReportNotFound
      end

      def current(report_type:, interval:)
        date = _current_date
        time_period = TimePeriod.new(interval:, date:)
        klass_for_interval(interval).new(time_period:, report_type:)
      end

      def klass_for_interval(interval)
        klass_name = "#{Types::TemporalInterval[interval]}_report".camelize
        Reporting.const_get(klass_name)
      rescue Dry::Types::ConstraintError
        raise Reporting::ReportNotFound
      end

      def _current_date
        Time.current.in_time_zone('London').to_date
      end
    end
  end
end
