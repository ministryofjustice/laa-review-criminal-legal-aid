class CspViolationMiddleware < PrometheusExporter::Middleware
  def custom_labels(env)
    labels = {
      csp_violations: 'laa-review'
    }

    if env['HTTP_X_PLATFORM']
      labels['platform'] = env['HTTP_X_PLATFORM']
    end

    labels
  end
end
