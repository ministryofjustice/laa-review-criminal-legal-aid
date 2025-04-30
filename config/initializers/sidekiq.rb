require 'host_env'

return if HostEnv.production?

# For k8s readiness probe - taken from https://github.com/sidekiq/sidekiq/wiki/Kubernetes#sidekiq
SIDEKIQ_WILL_PROCESSES_JOBS_FILE = Rails.root.join('tmp/sidekiq_process_has_started_and_will_begin_processing_jobs').freeze

Sidekiq.configure_server do |config|
  break unless ENV.fetch('ENABLE_PROMETHEUS_EXPORTER', 'false').inquiry.true?

  require 'prometheus_exporter/client'
  require 'prometheus_exporter/instrumentation'

  config.server_middleware do |chain|
    chain.add PrometheusExporter::Instrumentation::Sidekiq
  end
  config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler
  config.on :startup do
    FileUtils.touch(SIDEKIQ_WILL_PROCESSES_JOBS_FILE)

    PrometheusExporter::Instrumentation::Process.start type: 'sidekiq'
    PrometheusExporter::Instrumentation::SidekiqProcess.start
    PrometheusExporter::Instrumentation::SidekiqQueue.start(all_queues: true)
    PrometheusExporter::Instrumentation::SidekiqStats.start
  end

  config.on :shutdown do
    FileUtils.rm_f(SIDEKIQ_WILL_PROCESSES_JOBS_FILE)
  end

  at_exit do
    PrometheusExporter::Client.default.stop(wait_timeout_seconds: 10)
  end
end
