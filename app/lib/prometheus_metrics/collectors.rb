module PrometheusMetrics
  module Collectors
    # class CspViolation
    #   def initialize
    #     metric
    #   end

    #   def metric
    #     @metric ||= PrometheusExporter::Metric::Counter.new('csp_violations', 'number of CSP violations recorded')
    #   end
    # end

    class CspViolation
      include Singleton
      def client
        @client ||= PrometheusExporter::Client.default
      end

      def self.counters(*args)
        instance.counters(*args)
      end

      def counters
        @counters ||= Hash.new do |hash, key|
          hash[key] = client.register(:counter, key, "Count of #{key}")
        end
      end
    end
  end
end
