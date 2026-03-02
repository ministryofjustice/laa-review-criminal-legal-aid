require 'rails_helper'

describe Reviewing::Review do
  subject(:review) { described_class.new(SecureRandom.uuid) }

  let(:reason) { 'case_concluded' }

  let(:application_id) { SecureRandom.uuid }
  let(:reference) { 123_456 }

  let(:submitted_at) { Time.zone.now }
  let(:application_type) { Types::ApplicationType['initial'] }

  describe '#receive_application' do
    before do
      review.receive_application(submitted_at:, application_type:, reference:)
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
        expect { review.receive_application(submitted_at:, application_type:, reference:) }.to raise_error(
          Reviewing::AlreadyReceived
        )
      end
    end
  end

  describe 'sending back a received application' do
    let(:user_id) { SecureRandom.uuid }

    before do
      review.receive_application(submitted_at:, application_type:, reference:)
      review.send_back(user_id:, reason:)
    end

    it 'becomes "sent_back"' do
      expect(review.state).to eq :sent_back
      expect(review.reviewed_at).to be_present
    end

    it 'becomes "reviewed"' do
      expect(review).to be_reviewed
    end

    it 'creates an event' do
      expect(review.unpublished_events.map(&:event_type)).to match [
        'Reviewing::ApplicationReceived', 'Reviewing::SentBack'
      ]
    end

    it 'can only happen once' do
      expect do
        review.send_back(user_id:, reason:)
      end.to raise_error Reviewing::AlreadyReviewed
    end

    it 'cannot then be completed' do
      expect do
        review.complete(user_id:)
      end.to raise_error Reviewing::AlreadyReviewed
    end

    it 'cannot then be marked as ready' do
      expect do
        review.mark_as_ready(user_id:)
      end.to raise_error Reviewing::AlreadyReviewed
    end
  end

  describe 'completing a received application' do
    let(:user_id) { SecureRandom.uuid }

    before do
      review.receive_application(submitted_at:, application_type:, reference:)
      review.complete(user_id:)
    end

    it 'becomes "completed"' do
      expect(review.state).to eq :completed
    end

    it 'becomes "reviewed"' do
      expect(review).to be_reviewed
    end

    it 'creates an event' do
      expect(review.unpublished_events.map(&:event_type)).to match [
        'Reviewing::ApplicationReceived', 'Reviewing::Completed'
      ]
    end

    it 'can only happen once' do
      expect { review.complete(user_id:) }.to raise_error(
        Reviewing::AlreadyReviewed
      )
    end

    it 'cannot then be sent back' do
      expect do
        review.send_back(user_id:, reason:)
      end.to raise_error Reviewing::AlreadyReviewed
    end

    it 'cannot then be marked as ready' do
      expect do
        review.mark_as_ready(user_id:)
      end.to raise_error Reviewing::AlreadyReviewed
    end
  end

  describe 'marking a received application as ready for assessment' do
    let(:user_id) { SecureRandom.uuid }

    before do
      review.receive_application(submitted_at:, application_type:, reference:)
      review.mark_as_ready(user_id:)
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
      expect { review.mark_as_ready(user_id:) }.to raise_error(
        Reviewing::AlreadyMarkedAsReady
      )
    end

    it 'can then be sent back' do
      review.send_back(user_id:, reason:)
      expect(review.state).to eq :sent_back
    end
  end

  describe 'adding a reference to a received application' do
    let(:new_reference) { 789_012 }

    before do
      review.receive_application(submitted_at: submitted_at, application_type: application_type, reference: nil)
    end

    context 'when a ReferenceAdded event is applied' do
      before do
        review.apply(
          Reviewing::ReferenceAdded.new(data: { application_id: review.application_id, reference: new_reference })
        )
      end

      it 'sets the reference' do
        expect(review.reference).to eq new_reference
      end

      it 'creates an event' do
        expect(review.unpublished_events.map(&:event_type)).to include(
          'Reviewing::ReferenceAdded'
        )
      end
    end

    context 'when reference was already set via ApplicationReceived' do
      subject(:review_with_ref) { described_class.new(SecureRandom.uuid) }

      before do
        review_with_ref.receive_application(submitted_at:, application_type:, reference:)
        review_with_ref.apply(
          Reviewing::ReferenceAdded.new(data: { application_id: review_with_ref.application_id,
                                                reference: new_reference })
        )
      end

      it 'overwrites the reference' do
        expect(review_with_ref.reference).to eq new_reference
      end
    end
  end

  describe 'adding a decision' do
    let(:user_id) { SecureRandom.uuid }

    before do
      review.receive_application(submitted_at:, application_type:, reference:)
    end

    context 'when already reviewed' do
      before do
        review.complete(user_id:)
      end

      it 'raises AlreadyReviewed' do
        expect { review.add_decision(decision_id: SecureRandom.uuid) }.to raise_error(Reviewing::AlreadyReviewed)
      end
    end
  end

  describe 'removing a decision' do
    let(:user_id) { SecureRandom.uuid }

    before do
      review.receive_application(submitted_at:, application_type:, reference:)
    end

    context 'when already reviewed' do
      before do
        review.complete(user_id:)
      end

      it 'raises AlreadyReviewed' do
        expect do
          review.remove_decision(decision_id: SecureRandom.uuid, user_id: user_id)
        end.to raise_error(Reviewing::AlreadyReviewed)
      end
    end

    context 'when the decision is not linked' do
      it 'raises DecisionNotLinked' do
        expect do
          review.remove_decision(decision_id: SecureRandom.uuid, user_id: user_id)
        end.to raise_error(Reviewing::DecisionNotLinked)
      end
    end
  end
end
