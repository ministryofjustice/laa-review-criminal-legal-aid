module PrometheusMetrics
  require 'prometheus_exporter/middleware'

  class GrapeMiddleware < PrometheusExporter::Middleware
    def custom_labels(env)
      return unless env['api.endpoint']

      api_version = env['api.version'] || 'n/a'
      api_namespace = env['api.endpoint'].namespace
      api_method = env['api.endpoint'].options[:method].first

      {
        api_version:,
        api_namespace:,
        api_method:,
      }
    rescue StandardError
      nil
    end
  end
end
