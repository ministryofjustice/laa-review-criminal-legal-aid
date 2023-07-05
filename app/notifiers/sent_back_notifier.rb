class SentBackNotifier
  def call(event)
    Rails.error.handle do
      application_id = event.data.fetch(:application_id)
      return_reason = event.data.fetch(:reason)

      NotifyMailer.application_returned_email(
        application_id, return_reason
      ).deliver_now
    end
  end
end
