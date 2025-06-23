require 'sidekiq'
require 'sidekiq/api'

module PrometheusMetrics
  module Configuration
    require 'prometheus_exporter/server'
    require_relative 'collectors'

    DEFAULT_PREFIX = 'ruby_'.freeze
    CUSTOM_COLLECTORS = [
      # Add custom collector classes here
    ].freeze

    # :nocov:
    def self.should_configure?
      return false if ENV.key?('SKIP_PROMETHEUS_EXPORTER')
      return false unless rails_server? || sidekiq?

      ENV.fetch('ENABLE_PROMETHEUS_EXPORTER', 'false').inquiry.true?
    end

    # We are running puma in single process mode, so this is safe
    # If we move to multi process mode, we will have to run the
    # exporter process separately (`bundle exec prometheus_exporter`)
    def self.start_server
      port = ENV.fetch('PROMETHEUS_EXPORTER_PORT', 9394).to_i
      server = PrometheusExporter::Server::WebServer.new(
        bind: '0.0.0.0', port: port,
        verbose: ENV.fetch('PROMETHEUS_EXPORTER_VERBOSE', 'false').inquiry.true?
      )

      # Register any custom collectors
      CUSTOM_COLLECTORS.each { |klass| server.collector.register_collector(klass.new) }

      server.start

      true
    rescue Errno::EADDRINUSE
      warn "[PrometheusExporter] Server port `#{port}` already in use."
      false
    end

    def self.rails_server?
      defined?(Rails) && (Rails.const_defined?('Rails::Server') || File.basename($PROGRAM_NAME) == 'puma')
    end

    def self.sidekiq?
      Sidekiq.server?
    end

    def self.configure
      return unless should_configure?
      return unless start_server

      require 'prometheus_exporter/instrumentation'
      require 'prometheus_exporter/middleware'

      Rails.logger.info '[PrometheusExporter] Initialising instrumentation middleware...'

      # Metrics will be prefixed, for example `ruby_http_requests_total`
      PrometheusExporter::Metric::Base.default_prefix = DEFAULT_PREFIX

      config_rails_instrumentation if rails_server?
      config_sidekiq_instrumentation if sidekiq?
    end

    def self.config_rails_instrumentation
      # This reports stats per request like HTTP status and timings
      Rails.application.middleware.unshift PrometheusExporter::Middleware

      # This reports basic process stats like RSS and GC info, type master
      # means it is instrumenting the master process
      PrometheusExporter::Instrumentation::Process.start(type: 'master')

      # NOTE: if running Puma in cluster mode, the following
      # instrumentation will need to be changed
      PrometheusExporter::Instrumentation::Puma.start unless PrometheusExporter::Instrumentation::Puma.started?

      # NOTE: if running Puma in cluster mode, the following
      # instrumentation will need to be changed
      PrometheusExporter::Instrumentation::ActiveRecord.start
    end

    def self.config_sidekiq_instrumentation # rubocop:disable Metrics/MethodLength
      Sidekiq.configure_server do |config|
        require 'prometheus_exporter/client'

        config.server_middleware do |chain|
          chain.add PrometheusExporter::Instrumentation::Sidekiq
        end
        config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler
        config.on :startup do
          PrometheusExporter::Instrumentation::Process.start type: 'sidekiq'
          PrometheusExporter::Instrumentation::SidekiqProcess.start
          PrometheusExporter::Instrumentation::SidekiqQueue.start(all_queues: true)
          PrometheusExporter::Instrumentation::SidekiqStats.start
        end

        at_exit do
          PrometheusExporter::Client.default.stop(wait_timeout_seconds: 10)
        end
      end
    end
    # :nocov:
  end
end
