require 'pry'
class NotifyMailer < GovukNotifyRails::Mailer
  # Define methods as usual, and set the template and personalisation accordingly
  # Then just use mail() as with any other ActionMailer, with the recipient email.
  before_action do
    @template_ids = Rails.configuration.govuk_notify_templates
  end

  def application_returned_email(crime_application)
    provider_email = crime_application.provider_details.provider_email
    applicant_name = crime_application.applicant_name
    application_reference = crime_application.reference.to_s

    set_template(:application_returned_email)

    set_personalisation(
      applicant_name:,
      application_reference:
    )

    mail(to: provider_email)
  end

  protected

  # rubocop:disable Naming/AccessorMethodName
  def set_template(name)
    super(@template_ids.fetch(name))
  end
  # rubocop:enable Naming/AccessorMethodName
end
