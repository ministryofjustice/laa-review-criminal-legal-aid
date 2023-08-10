module PrometheusMetrics
  module Collectors
    class CspViolation
      def initialize
        metric
      end

      def metric
        @metric ||= begin
          PrometheusExporter::Metric::Counter.new('csp_violations', 'number of CSP violations recorded')
        end
      end
    end
  end
end
