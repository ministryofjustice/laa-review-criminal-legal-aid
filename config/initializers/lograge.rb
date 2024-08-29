Rails.application.configure do
  config.lograge.enabled = Rails.env.production?

  config.lograge.base_controller_class = 'ActionController::Base'
  config.lograge.logger = ActiveSupport::Logger.new($stdout)
  config.lograge.formatter = Lograge::Formatters::Logstash.new


  # Commenting out ignoring of healthcheck to aid with debugging
  # # Reduce noise in the logs by ignoring the healthcheck actions
  # config.lograge.ignore_actions = %w[
  #   HealthcheckController#show
  #   HealthcheckController#ping
  #   DatastoreApi::HealthEngine::HealthcheckController#show
  #   DatastoreApi::HealthEngine::HealthcheckController#ping
  # ]

  config.lograge.custom_options = lambda do |event|
    request = event.payload[:request]

    {
      process_id: Process.pid,
      host: request.host,
      request_id: request.request_id,
      user_agent: request.user_agent,
      params: request.filtered_parameters.except(
        *%w[controller action format id]
      ),
    }.compact_blank
  end

  config.lograge.custom_payload do |controller|
    {
      user_id: controller.current_user.to_param,
    }
  end
end
