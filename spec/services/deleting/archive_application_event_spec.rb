require 'rails_helper'

RSpec.describe Deleting::ArchiveApplicationEvent do
  let(:application_id) { SecureRandom.uuid }
  let(:reference) { 12_345_678 }
  let(:message_id) { SecureRandom.uuid }
  let(:event_store) { Rails.configuration.event_store }

  let(:data) do
    {
      'id' => application_id,
      'application_type' => 'initial',
      'reference' => reference,
      'archived_at' => '2026-02-11T09:00:00.000Z'
    }
  end

  describe '.call' do
    subject(:call) { described_class.call(id: message_id, data: data) }

    context 'when the application has not been archived before' do
      it 'publishes a Deleting::Archived event' do
        expect { call }.to change {
          event_store.read.of_type([Deleting::Archived]).count
        }.by(1)
      end

      it 'includes the correct data in the event' do
        call

        event = event_store.read.of_type([Deleting::Archived]).last
        expect(event.data).to include(
          application_id: application_id,
          application_type: 'initial',
          reference: reference,
          archived_at: '2026-02-11T09:00:00.000Z'
        )
      end
    end

    context 'when the application has already been archived' do
      before do
        event = Deleting::Archived.new(
          data: {
            application_id: application_id,
            application_type: 'initial',
            reference: reference,
            archived_at: '2026-01-01T09:00:00.000Z'
          }
        )
        event_store.publish(event)
        event_store.link(event.event_id, stream_name: ReferenceHistory.stream_name(reference))
        allow(Rails.logger).to receive(:warn)
      end

      it 'does not publish another Deleting::Archived event' do
        expect { call }.not_to(change do
          event_store.read.of_type([Deleting::Archived]).count
        end)
      end

      it 'logs a warning' do
        call
        expect(Rails.logger).to have_received(:warn).with('Application already archived')
      end
    end

    context 'when a different application has been archived' do
      let(:other_reference) { 99_999_999 }

      before do
        event = Deleting::Archived.new(
          data: {
            application_id: SecureRandom.uuid,
            application_type: 'initial',
            reference: other_reference,
            archived_at: '2026-01-01T09:00:00.000Z'
          }
        )
        event_store.publish(event)
        event_store.link(event.event_id, stream_name: ReferenceHistory.stream_name(other_reference))
      end

      it 'publishes a Deleting::Archived event for the new application' do
        expect { call }.to change {
          event_store.read.of_type([Deleting::Archived]).count
        }.by(1)
      end
    end
  end
end
