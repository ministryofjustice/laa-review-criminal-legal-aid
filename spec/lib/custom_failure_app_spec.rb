require 'rails_helper'

RSpec.describe CustomFailureApp do
  describe '#i18n_message' do
    let(:app) { described_class.new }

    context 'when the translated message is a plain string' do
      before do
        allow(app).to receive_messages(warden_message: :invalid, scope: 'user', i18n_options: {},
                                       base_i18n_options: {}, human_authentication_keys: %w[email])
        allow(I18n).to receive(:t).and_return('Invalid email or password.')
      end

      it 'returns the capitalised string' do
        expect(app.send(:i18n_message)).to eq('Invalid email or password.')
      end
    end

    context 'when the translated message is an Array' do
      before do
        allow(app).to receive_messages(warden_message: :invalid, scope: 'user', i18n_options: {}, base_i18n_options: {})
        allow(I18n).to receive(:t).and_return(%w[Title Body])
      end

      it 'returns the array as-is' do
        expect(app.send(:i18n_message)).to eq(%w[Title Body])
      end
    end
  end

  describe '#capitalize_message' do
    let(:app) { described_class.new }

    before do
      allow(app).to receive(:human_authentication_keys).and_return(%w[email])
    end

    context 'when the message starts with the authentication key' do
      it 'upcases the first character' do
        expect(app.send(:capitalize_message, 'email not found')).to eq('Email not found')
      end
    end

    context 'when the message does not start with the authentication key' do
      it 'returns the message unchanged' do
        expect(app.send(:capitalize_message, 'invalid credentials')).to eq('invalid credentials')
      end
    end
  end
end
