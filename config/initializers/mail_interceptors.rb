require_relative '../../app/lib/host_env'

Rails.application.configure do
  if HostEnv.env_name == 'staging'
    config.action_mailer.interceptors = %w[NotifyMailerInterceptor]
  end
end

