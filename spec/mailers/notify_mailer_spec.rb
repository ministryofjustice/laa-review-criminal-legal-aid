require 'rails_helper'

RSpec.describe NotifyMailer do
  let(:attributes) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }
  let(:crime_application) { CrimeApplication.new(attributes) }

  before do
    allow(Rails.configuration).to receive(:govuk_notify_templates).and_return(
      application_returned_email: 'application_returned_email_template_id'
    )

    allow(CrimeApplication).to receive(:find)
      .with(crime_application.id)
      .and_return(crime_application)
  end

  describe '#application_returned_email' do
    let(:mail) do
      described_class.application_returned_email(
        crime_application.id, :clarification_required
      )
    end

    let(:personalisation) do
      {
        applicant_name: 'Kit Pound',
        application_reference: '6000001',
        return_reason: 'Clarification required'
      }
    end

    it_behaves_like 'a Notify mailer', template_id: 'application_returned_email_template_id'

    it { expect(mail.to).to eq(['provider@example.com']) }

    it 'has the right personalisation' do
      expect(mail.govuk_notify_personalisation).to eq(personalisation)
    end
  end
end
