module Reporting
  class TemporalReport
    include ActiveModel::Model

    attr_reader :time_period, :report_type, :page, :sorting

    def initialize(time_period:, report_type:, sorting: {}, page: 1)
      @time_period = time_period
      @report_type = Types::TemporalReportType[report_type]
      @sorting = Reporting.const_get("#{report_type}_sorting".camelize).new_or_default(sorting)
      @page = page
    end

    def to_param
      {
        report_type: report_type,
        interval: time_period.interval,
        period: period_as_param
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

    def report
      @report ||= read_model_klass.for_time_period(time_period:, sorting:, page:)
    end

    def rows
      @rows ||= report.rows
    end

    delegate :total_count, :pagination, :downloadable?, to: :report

    def csv(file: 1)
      @csv ||= report.csv(file:)
    end

    def csv_filename(file: 1)
      "#{id}_#{file}_of_#{report.csv_file_count}.csv"
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

    def period_as_param
      time_period.starts_on.strftime(self.class::PARAM_FORMAT)
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
      def from_param(report_type:, period:, interval:, sorting: {}, page: 1)
        klass = klass_for_interval(interval)
        date = Date.strptime(period, klass::PARAM_FORMAT)
        time_period = TimePeriod.new(interval:, date:)

        klass_for_interval(interval).new(
          time_period:, report_type:, sorting:, page:
        )
      rescue Date::Error
        raise Reporting::ReportNotFound
      end

      def current(report_type:, interval:, sorting: {}, page: 1)
        date = _current_date
        time_period = TimePeriod.new(interval:, date:)

        klass_for_interval(interval).new(
          time_period:, report_type:, sorting:, page:
        )
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
