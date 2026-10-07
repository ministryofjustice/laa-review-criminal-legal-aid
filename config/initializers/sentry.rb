Rails.application.config.to_prepare do
  # Sentry is enabled if SENTRY_DSN environment variable is set
  Sentry.init do |config|
    config.rails.report_rescued_exceptions = true
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.environment = HostEnv.env_name

    # to enable performance
    config.traces_sample_rate = 0.05

    # to enable profiling
    config.profiles_sample_rate = 0.05

    # Contrary to what is stated in https://edgeguides.rubyonrails.org/error_reporting.html,
    # Sentry currently requires explicit configuration in order to register as a subscriber.
    # See discussion on GitHub at https://github.com/rails/rails/pull/43625#issuecomment-1072514175.
    config.rails.register_error_subscriber = true

    config.rails.structured_logging.enabled = false

    # Filtering
    # https://docs.sentry.io/platforms/ruby/guides/rails/configuration/filtering/
    
    config.data_collection.user_info = false
    config.data_collection.cookies = false
    config.data_collection.http_headers.request.mode = :deny_list
    config.data_collection.http_headers.request.terms = Sentry::DataCollection::PII_HEADER_SNIPPETS
    config.data_collection.http_headers.response.mode = :deny_list
    config.data_collection.http_headers.response.terms = Sentry::DataCollection::PII_HEADER_SNIPPETS
    config.data_collection.http_bodies = []
    config.data_collection.url_query_params = false
    config.data_collection.graphql.document = false
    config.data_collection.graphql.variables = false
    config.data_collection.database_query_data = false
    config.data_collection.queues = false
    config.data_collection.stack_frame_variables = false

    params_filter = ActiveSupport::ParameterFilter.new(
      Rails.application.config.filter_parameters
    )
    config.before_send = lambda do |event, _hint|
      if event.request
        event.request.data = params_filter.filter(event.request.data) if event.request.data
        event.request.cookies = params_filter.filter(event.request.cookies) if event.request.cookies

        if event.request.query_string.present?
          parsed = Rack::Utils.parse_nested_query(event.request.query_string)
          event.request.query_string = params_filter.filter(parsed).to_query
        end
      end

      if event.user
        event.user = params_filter.filter(event.user)
      end

      event
    end
  end
end
