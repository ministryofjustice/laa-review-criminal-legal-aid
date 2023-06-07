class SentBackNotifier
  def call(event)
    application_id = event.data.fetch(:application_id)
    return_reason = event.data.fetch(:reason)

    NotifyMailer.application_returned_email(application_id, return_reason).deliver_now

  # Rescue and report exceptions
  # Notifying should not block
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
