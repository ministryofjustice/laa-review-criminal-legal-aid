require 'rails_helper'

RSpec.describe ReferenceHistory::LinkToReferenceStream do
  let(:event_store) { instance_double(RailsEventStore::Client) }
  let(:application_id) { SecureRandom.uuid }
  let(:reference) { 100_123 }

  describe '#call' do
    subject(:call) { described_class.new(event_store:).call(event) }

    before do
      allow(event_store).to receive(:link)
    end

    context 'when the event includes a reference in its data (reviewing events)' do
      let(:event) do
        Reviewing::ApplicationReceived.new(data: { reference:, application_id: })
      end

      before do
        allow(Review).to receive(:find_by)
        call
      end

      it 'links the event to the reference stream' do
        expect(event_store).to have_received(:link).with(
          event.event_id,
          stream_name: ReferenceHistory.stream_name(reference)
        )
      end

      it 'does not need to look up a review' do
        expect(Review).not_to have_received(:find_by)
      end
    end

    context 'when the event does not include a reference (assigning events)' do
      let(:event) do
        Assigning::AssignedToUser.new(
          data: { assignment_id: application_id, to_whom_id: SecureRandom.uuid }
        )
      end

      let(:review) { instance_double(Review, reference:) }

      before do
        allow(Review).to receive(:find_by).with(application_id:).and_return(review)
        call
      end

      it 'looks up the review based on the application id derived from the event data' do
        expect(Review).to have_received(:find_by).with(application_id:)
      end

      it 'links the event to the reference stream' do
        expect(event_store).to have_received(:link).with(
          event.event_id,
          stream_name: ReferenceHistory.stream_name(reference)
        )
      end
    end

    context 'when the event does not include a reference and the review cannot be found' do
      let(:event) do
        Assigning::AssignedToUser.new(
          data: { assignment_id: application_id, to_whom_id: SecureRandom.uuid }
        )
      end

      before do
        allow(Review).to receive(:find_by).with(application_id:).and_return(nil)
        call
      end

      it 'does not link the event' do
        expect(event_store).not_to have_received(:link)
      end
    end

    context 'when no application id can be derived from the event data' do
      let(:event) do
        Assigning::AssignedToUser.new(
          data: { to_whom_id: SecureRandom.uuid }
        )
      end

      before { call }

      it 'does not link the event' do
        expect(event_store).not_to have_received(:link)
      end
    end

    context 'when the reference is blank' do
      let(:event) do
        Reviewing::ApplicationReceived.new(
          data: { reference: '   ', application_id: SecureRandom.uuid }
        )
      end

      before { call }

      it 'does not link the event' do
        expect(event_store).not_to have_received(:link)
      end
    end
  end
end
