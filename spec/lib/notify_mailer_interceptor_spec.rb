require 'rails_helper'

describe NotifyMailerInterceptor do
  let(:message) do
    Mail::Message.new(
      from: ['from@example.com'],
      to: ['recipient@example.com']
    )
  end

  before do
    allow(HostEnv).to receive(:env_name).and_return('staging')
    allow(ENV).to receive(:fetch)
      .with('STAGING_GROUP_INBOX', nil)
      .and_return('staging-group-inbox@example.com')
  end

  context 'with different environments' do
    describe 'staging' do
      it 'reroutes emails to staging inbox' do
        described_class.delivering_email(message)
        expect(message.to).to eq(['staging-group-inbox@example.com'])
      end

      it 'performs deliveries' do
        expect(message.perform_deliveries).to be(true)
      end
    end

    describe 'development' do
      it 'reroutes emails to staging inbox' do
        allow(HostEnv).to receive(:env_name).and_return('development')
        described_class.delivering_email(message)
        expect(message.to).to eq(['recipient@example.com'])
      end
    end
  end
end
