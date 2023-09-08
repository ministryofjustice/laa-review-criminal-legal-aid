require 'rails_helper'

RSpec.describe NotifyMailer do
  let(:attributes) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }
  let(:crime_application) { CrimeApplication.new(attributes) }

  before do
    allow(Rails.configuration).to receive(:govuk_notify_templates).and_return(
      application_returned_email: 'application_returned_email_template_id',
      access_granted_email: 'access_granted_email_template_id',
      onboarding_reply_to_address: 'onboarding_reply_to_address',
      revive_account_email: 'revive_account_email_template_id',
      role_changed_email: 'role_changed_email_template_id'
    )
  end

  describe '#application_returned_email' do
    before do
      allow(CrimeApplication).to receive(:find)
        .with(crime_application.id)
        .and_return(crime_application)
    end

    let(:mail) do
      described_class.application_returned_email(
        crime_application.id, :clarification_required
      )
    end

    let(:personalisation) do
      {
        applicant_name: 'Kit Pound',
        application_reference: '6000001',
        return_reason: 'clarification is required'
      }
    end

    it_behaves_like 'a Notify mailer', template_id: 'application_returned_email_template_id'

    it { expect(mail.to).to eq(['provider@example.com']) }

    it 'has the right personalisation' do
      expect(mail.govuk_notify_personalisation).to eq(personalisation)
    end
  end

  describe '#access_granted_email' do
    let(:mail) do
      described_class.access_granted_email('test@example.com')
    end

    it_behaves_like 'a Notify mailer', template_id: 'access_granted_email_template_id'

    it { expect(mail.to).to eq(['test@example.com']) }
    it { expect(mail.govuk_notify_email_reply_to).to eq('onboarding_reply_to_address') }
  end

  describe '#revive_account_email' do
    let(:mail) do
      described_class.revive_account_email('test@example.com')
    end

    let(:personalisation) do
      {
        num_hours: 48,
        onboarding_email: 'LAAapplyonboarding@justice.gov.uk'
      }
    end

    it_behaves_like 'a Notify mailer', template_id: 'revive_account_email_template_id'

    it { expect(mail.to).to eq(['test@example.com']) }
    it { expect(mail.govuk_notify_email_reply_to).to eq('onboarding_reply_to_address') }
    it { expect(mail.govuk_notify_personalisation).to eq(personalisation) }
  end

  describe '#role_changed_email' do
    user = User.new(
      email: 'supervisor@example.com',
      role: 'supervisor',
      first_name: 'Homer',
      last_name: 'Simpson'
    )

    let(:mail) do
      described_class.role_changed_email(%w[test@example.com other_admin@example.com], user)
    end

    let(:personalisation) do
      {
        user_name: 'Homer Simpson',
        role_name: 'Supervisor',
        onboarding_email: 'LAAapplyonboarding@justice.gov.uk'
      }
    end

    it_behaves_like 'a Notify mailer', template_id: 'role_changed_email_template_id'

    it { expect(mail.to).to eq(%w[test@example.com other_admin@example.com]) }
    it { expect(mail.govuk_notify_email_reply_to).to eq('onboarding_reply_to_address') }
    it { expect(mail.govuk_notify_personalisation).to eq(personalisation) }
  end
end
