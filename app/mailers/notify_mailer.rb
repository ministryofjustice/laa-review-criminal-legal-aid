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

  def application_returned_email(application_id, return_reason)
    application = CrimeApplication.find(application_id)
    provider_email = application.provider_details.provider_email
    applicant_name = application.applicant_name
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

    mail(to: email)
  end

  protected

  # rubocop:disable Naming/AccessorMethodName
  def set_template(name)
    super(@template_ids.fetch(name))
  end
  # rubocop:enable Naming/AccessorMethodName
  #
end
