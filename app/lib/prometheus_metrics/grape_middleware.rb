module PrometheusMetrics
  require 'prometheus_exporter/middleware'

  class GrapeMiddleware < PrometheusExporter::Middleware
    def default_labels(env, result)
      if _api_request?(env)
        {
          controller: '(api)',
          action: env['api.endpoint'].namespace,
        }
      else
        super
      end
    end

    def custom_labels(env)
      return unless _api_request?(env)

      api_version = env['api.version'] || 'n/a'
      api_method = env['api.endpoint'].options[:method].first

      {
        api_version:,
        api_method:,
      }
    rescue StandardError
      nil
    end

    private

    def _api_request?(env)
      env['api.endpoint'].present?
    end
  end
end
