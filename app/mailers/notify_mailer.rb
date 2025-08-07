class NotifyMailer < GovukNotifyRails::Mailer
  # Define methods as usual, and set the template and personalisation accordingly
  # Then just use mail() as with any other ActionMailer, with the recipient email.
  before_action do
    @template_ids = Rails.configuration.govuk_notify_templates
  end

  # :nocov:
  rescue_from 'Notifications::Client::BadRequestError' do |message|
    Rails.logger.warn message.to_s
  end
  # :nocov:

  self.delivery_job = NotifyMailDeliveryJob

  def application_returned_email(application_id, return_reason)
    application = CrimeApplication.find(application_id)
    provider_email = application.provider_details.provider_email
    applicant_name = application.client_details.applicant.full_name
    application_reference = application.reference.to_s
    return_reason = I18n.t("emails_text.application_returned.#{return_reason}")

    set_template(:application_returned_email)

    set_personalisation(
      applicant_name:,
      application_reference:,
      return_reason:
    )

    mail(to: provider_email)
  end

  def access_granted_email(email)
    set_template(:access_granted_email)
    set_email_reply_to(:onboarding_reply_to_address)

    mail(to: email)
  end

  def revive_account_email(email)
    set_template(:revive_account_email)
    set_email_reply_to(:onboarding_reply_to_address)

    set_personalisation(
      num_hours: Rails.configuration.x.auth.dormant_account_revive_ttl.in_hours.round,
      onboarding_email: Rails.configuration.x.admin.onboarding_email
    )

    mail(to: email)
  end

  def role_changed_email(emails, user)
    set_template(:role_changed_email)
    set_email_reply_to(:onboarding_reply_to_address)

    set_personalisation(
      user_name: user.name,
      role_name: user.role.humanize,
      onboarding_email: Rails.configuration.x.admin.onboarding_email
    )

    mail(to: [emails].flatten.compact)
  end

  protected

  # rubocop:disable Naming/AccessorMethodName
  def set_template(name)
    super(@template_ids.fetch(name))
  end

  def set_email_reply_to(name)
    super(@template_ids.fetch(name))
  end
  # rubocop:enable Naming/AccessorMethodName
  #
end
