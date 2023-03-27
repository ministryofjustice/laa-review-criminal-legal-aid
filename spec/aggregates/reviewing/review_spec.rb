require 'aggregates_helper'
require_relative '../../../app/aggregates/reviewing'

describe Reviewing::Review do
  subject(:review) { described_class.new(SecureRandom.uuid) }

  let(:reason) { 'case_concluded' }

  let(:application_id) { SecureRandom.uuid }

  let(:submitted_at) { Time.zone.now }

  describe '#recieve_application' do
    before do
      review.receive_application(submitted_at:)
    end

    it 'becomes "received"' do
      expect(review.state).to eq :open
    end

    it 'creates an event' do
      expect(review.unpublished_events.map(&:event_type)).to match [
        'Reviewing::ApplicationReceived'
      ]
    end

    context 'when has already been received' do
      it 'raises AlreadyReceived' do
        expect { review.receive_application(submitted_at:) }.to raise_error(
          Reviewing::AlreadyReceived
        )
      end
    end
  end

  describe 'sending back a received application' do
    let(:user_id) { SecureRandom.uuid }

    before do
      review.receive_application(submitted_at:)
      review.send_back(user_id:, reason:)
    end

    it 'becomes "sent_back"' do
      expect(review.state).to eq :sent_back
    end

    it 'creates an event' do
      expect(review.unpublished_events.map(&:event_type)).to match [
        'Reviewing::ApplicationReceived', 'Reviewing::SentBack'
      ]
    end

    it 'can only happen once' do
      expect do
        review.send_back(user_id:, reason:)
      end.to raise_error Reviewing::AlreadySentBack
    end

    it 'cannot then be completed' do
      expect do
        review.complete(user_id:)
      end.to raise_error Reviewing::CannotCompleteWhenSentBack
    end

    it 'cannot then be marked as ready' do
      expect do
        review.mark_as_ready
      end.to raise_error Reviewing::CannotMarkAsReadyWhenSentBack
    end
  end

  describe 'completing a received application' do
    let(:user_id) { SecureRandom.uuid }

    before do
      review.receive_application(submitted_at:)
      review.complete(user_id:)
    end

    it 'becomes "completed"' do
      expect(review.state).to eq :completed
    end

    it 'creates an event' do
      expect(review.unpublished_events.map(&:event_type)).to match [
        'Reviewing::ApplicationReceived', 'Reviewing::Completed'
      ]
    end

    it 'can only happen once' do
      expect { review.complete(user_id:) }.to raise_error(
        Reviewing::AlreadyCompleted
      )
    end

    it 'cannot then be sent back' do
      expect do
        review.send_back(user_id:, reason:)
      end.to raise_error Reviewing::CannotSendBackWhenCompleted
    end

    it 'cannot then be marked as ready' do
      expect do
        review.mark_as_ready
      end.to raise_error Reviewing::CannotMarkAsReadyWhenCompleted
    end
  end

  describe 'marking a received application as ready for assessment' do
    let(:user_id) { SecureRandom.uuid }

    before do
      review.receive_application(submitted_at:)
      review.mark_as_ready
    end

    it 'becomes "marked as ready"' do
      expect(review.state).to eq :marked_as_ready
    end

    it 'creates an event' do
      expect(review.unpublished_events.map(&:event_type)).to match [
        'Reviewing::ApplicationReceived', 'Reviewing::MarkedAsReady'
      ]
    end

    it 'can only happen once' do
      expect { review.mark_as_ready }.to raise_error(
        Reviewing::AlreadyMarkedAsReady
      )
    end

    it 'cannot then be sent back' do
      expect do
        review.send_back(user_id:, reason:)
      end.to raise_error Reviewing::CannotSendBackWhenMarkedAsReady
    end
  end
end
