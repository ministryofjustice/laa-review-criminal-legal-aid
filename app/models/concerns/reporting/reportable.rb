module Reporting
  module Reportable
    extend ActiveSupport::Concern

    attr_reader :date, :report_type

    class_methods do
      def param_format
        self::PARAM_FORMAT
      end

      def supported_report_types
        Types::WeeklyReportType.values
      end

      def from_param(report_type:, epoch:)
        date = Date.strptime(epoch, param_format)
        new(report_type:, date:)
      end

      # Returns the latest fullreports for supported report types.
      # Optionally takes an array of report_types which can be used to filter the
      # report_types returned.
      def latest(report_types:)
        date = _latest_date

        (report_types & supported_report_types).map do |report_type|
          new(report_type:, date:)
        end
      end

      # :nocov:
      def _latest_date
        raise 'Implement in extended class.'
      end
      # :nocov:

      def _current_date
        Time.current.in_time_zone('London').to_date
      end
    end

    def to_param
      date.strftime(self.class.param_format)
    end

    def title
      report_text(:title, epoch_name:)
    end

    def rows
      @rows ||= Reporting.const_get(report_type.camelize).new(stream_name:).rows
    end

    private

    def report_text(key, options = {})
      I18n.t(key, scope: i18n_scope, **options)
    end

    def i18n_scope
      self.class.name.underscore.split('/') << report_type
    end
  end
end
