require_relative '../../app/lib/host_env'

Rails.application.configure do
  if HostEnv.staging?
    require_relative '../../app/lib/notify_mailer_interceptor'
    ActionMailer::Base.register_interceptor(NotifyMailerInterceptor)
  end
end

