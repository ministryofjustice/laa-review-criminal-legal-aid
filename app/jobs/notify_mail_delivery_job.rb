class NotifyMailDeliveryJob < ActionMailer::MailDeliveryJob
  self.log_arguments = false
end
