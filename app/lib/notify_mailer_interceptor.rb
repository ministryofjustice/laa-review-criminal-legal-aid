class NotifyMailerInterceptor
  class << self
    # Email interception configuration
    #
    # To facilitate debugging and testing, we allow email interception by setting
    # the environment variable 'INTERCEPT_EMAIL_ADDRESS'.
    #
    # If this variable is set, all outgoing emails will be intercepted and
    # forwarded to the specified email address.
    #
    # If the 'INTERCEPT_EMAIL_ADDRESS' variable is not set, emails will be sent
    # normally without interception.

    def delivering_email(message)
      return if intercept_email_address.nil?

      intercept_email!(message)
    end

    def intercept_email!(message)
      Rails.logger.warn 'Email intercepted and sent to the INTERCEPT_EMAIL_ADDRESS'
      message.to = intercept_email_address
    end

    def intercept_email_address
      ENV.fetch('INTERCEPT_EMAIL_ADDRESS', nil)
    end
  end
end
