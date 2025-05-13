# For k8s readiness probe - taken from https://github.com/sidekiq/sidekiq/wiki/Kubernetes#sidekiq
SIDEKIQ_WILL_PROCESSES_JOBS_FILE = Rails.root.join('tmp/sidekiq_process_has_started_and_will_begin_processing_jobs').freeze

Sidekiq.configure_server do |config|
  config.on :startup do
    FileUtils.touch(SIDEKIQ_WILL_PROCESSES_JOBS_FILE)
  end

  config.on :shutdown do
    FileUtils.rm_f(SIDEKIQ_WILL_PROCESSES_JOBS_FILE)
  end
end
