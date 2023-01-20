require 'aggregates_helper'
require_relative '../../../app/aggregates/reviewing'

describe Reviewing::Review do
  subject(:review) { described_class.new(SecureRandom.uuid) }

  let(:reason) { 'case_concluded' }

  let(:application_id) { SecureRandom.uuid }

  describe '#recieve_application' do
    before do
      review.receive_application(application_id:)
    end

    it 'is becomes "received"' do
      expect(review.state).to eq :received
    end

    it 'creates an event' do
      expect(review.unpublished_events.map(&:event_type)).to match [
        'Reviewing::ApplicationReceived'
      ]
    end

    context 'when has already been received' do
      it 'raises AlreadyReceived' do
        expect { review.receive_application(application_id:) }.to raise_error(
          Reviewing::AlreadyReceived
        )
      end
    end
  end

  describe 'sending back a received application' do
    let(:user_id) { SecureRandom.uuid }

    before do
      review.receive_application(application_id:)
      review.send_back(application_id:, user_id:, reason:)
    end

    it 'is becomes "sent_back"' do
      expect(review.state).to eq :sent_back
    end

    it 'creates an event' do
      expect(review.unpublished_events.map(&:event_type)).to match [
        'Reviewing::ApplicationReceived', 'Reviewing::SentBack'
      ]
    end

    it 'can only happen once' do
      expect do
        review.send_back(application_id:, user_id:, reason:)
      end.to raise_error Reviewing::AlreadySentBack
    end

    it 'cannot then be completed' do
      expect do
        review.complete(application_id:, user_id:)
      end.to raise_error Reviewing::CannotCompleteWhenSentBack
    end
  end

  describe 'completing a received application' do
    let(:user_id) { SecureRandom.uuid }

    before do
      review.receive_application(application_id:)
      review.complete(application_id:, user_id:)
    end

    it 'is becomes "completed"' do
      expect(review.state).to eq :completed
    end

    it 'creates an event' do
      expect(review.unpublished_events.map(&:event_type)).to match [
        'Reviewing::ApplicationReceived', 'Reviewing::Completed'
      ]
    end

    it 'can only happen once' do
      expect { review.complete(application_id:, user_id:) }.to raise_error(
        Reviewing::AlreadyCompleted
      )
    end

    it 'cannot then be sent back' do
      expect do
        review.send_back(application_id:, user_id:, reason:)
      end.to raise_error Reviewing::CannotSendBackWhenCompleted
    end
  end
end
