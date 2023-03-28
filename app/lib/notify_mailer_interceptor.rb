class NotifyMailerInterceptor
  class << self
    def delivering_email(message)
      return unless HostEnv.env_name == 'staging'

      intercept_email!(message)
    end

    def intercept_email!(message)
      Rails.logger.warn 'Email intercepted on staging'
      message.to = ENV.fetch('STAGING_GROUP_INBOX', nil)
    end
  end
end
