require 'rails_helper'

describe NotifyMailerInterceptor do
  let(:message) do
    Mail::Message.new(
      from: ['from@example.com'],
      to: ['recipient@example.com']
    )
  end

  before do
    described_class.delivering_email(message)
  end

  context 'when an intercept email is set' do
    before do
      allow(ENV).to receive(:fetch)
        .with('INTERCEPT_EMAIL_ADDRESS', nil)
        .and_return('staging-group-inbox@example.com')
    end

    it 'reroutes emails to the intercept email address' do
      described_class.delivering_email(message)
      expect(message.to).to eq(['staging-group-inbox@example.com'])
    end

    it 'performs deliveries' do
      expect(message.perform_deliveries).to be(true)
    end
  end

  context 'when an intercept email is not set' do
    it 'does not intercept' do
      expect(message.to).to eq(['recipient@example.com'])
    end

    it 'performs deliveries' do
      expect(message.perform_deliveries).to be(true)
    end
  end
end
