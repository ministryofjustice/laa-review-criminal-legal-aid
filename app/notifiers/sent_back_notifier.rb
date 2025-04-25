class SentBackNotifier
  def call(event)
    Rails.error.handle do
      application_id = event.data.fetch(:application_id)
      return_reason = event.data.fetch(:reason)

      if HostEnv.production?
        # :nocov:
        NotifyMailer.application_returned_email(application_id, return_reason).deliver_now
        # :nocov:
      else
        NotifyMailer.application_returned_email(application_id, return_reason).deliver_later
      end
    end
  end
end
