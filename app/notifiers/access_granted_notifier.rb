class AccessGrantedNotifier
  def call(event)
    email = User.find(event.data.fetch(:user_id)).email
    NotifyMailer.access_granted_email(email).deliver_now
    #
    # Rescue and report exceptions
    # Notifying should not block
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
