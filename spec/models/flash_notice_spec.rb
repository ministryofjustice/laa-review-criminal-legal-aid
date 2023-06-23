require 'rails_helper'

RSpec.describe FlashNotice do
  subject(:new) { described_class.new(key, message) }

  let(:key) { :success }
  let(:message) { 'Simple message' }

  describe '#text' do
    subject(:text) { new.text }

    context 'when the message is a string' do
      it { is_expected.to eq 'Simple message' }
    end

    context 'when the message is an array of one' do
      let(:message) { ['Simple message'] }

      it { is_expected.to eq 'Simple message' }
    end

    context 'when the message is an array of several' do
      let(:message) { ['Message with details', 'First detail.', 'Second detail.'] }

      it { is_expected.to eq 'Message with details' }
    end
  end

  describe '#details' do
    subject(:details) { new.details }

    context 'when the message is a string' do
      it { is_expected.to be_empty }
    end

    context 'when the message is an array of one' do
      let(:message) { ['Simple message'] }

      it { is_expected.to be_empty }
    end

    context 'when the message is an array of several' do
      let(:message) { ['Message with details', 'First detail.', 'Second detail.'] }

      it 'sets all but the first items in message as the details' do
        expect(details).to contain_exactly('First detail.', 'Second detail.')
      end
    end

    context 'when the message includes "ONBOARDING_EMAIL_LINK" placeholder in the details' do
      let(:message) { ['Message with mail link placeholder', 'Contact ONBOARDING_EMAIL_LINK for help.'] }

      it 'replaces the placeholder with the onboarding link' do
        expected_detail = "Contact <a href=\"mailto:#{Rails.application.config.x.admin.onboarding_email}\">" \
                          "#{Rails.application.config.x.admin.onboarding_email}</a> for help."

        expect(details.first).to eq expected_detail
      end
    end

    context 'when the message details include html tags' do
      let(:message) { ['Message with a link', 'Detail <em>with</em> html <a href="https://example.com">link</a> for help.'] }

      it 'tags are stripped from the details' do
        expect(details.first).to eq 'Detail with html link for help.'
      end
    end
  end

  describe '#success?' do
    subject(:success) { new.success? }

    context 'when key is "success"' do
      it { is_expected.to be true }
    end

    context 'when key is "alert"' do
      let(:key) { 'alert' }

      it { is_expected.to be false }
    end

    context 'when key is "notice"' do
      let(:key) { 'notice' }

      it { is_expected.to be true }
    end
  end

  describe '#title_text' do
    subject(:title_text) { new.title_text }

    context 'when key is "success"' do
      it { is_expected.to eq 'Success' }
    end

    context 'when key is "alert"' do
      let(:key) { 'alert' }

      it { is_expected.to eq 'Important' }
    end

    context 'when key is "notice"' do
      let(:key) { 'notice' }

      it { is_expected.to eq 'Success' }
    end
  end

  describe '#to_partial_path' do
    it 'is expected to equal "flash_message"' do
      expect(new.to_partial_path).to eq 'flash_notice'
    end
  end
end
