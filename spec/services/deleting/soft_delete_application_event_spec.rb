require 'rails_helper'

RSpec.describe Deleting::SoftDeleteApplicationEvent do
  let(:application_id) { SecureRandom.uuid }
  let(:reference) { 12_345_678 }
  let(:message_id) { SecureRandom.uuid }
  let(:event_store) { Rails.configuration.event_store }

  let(:data) do
    {
      'id' => application_id,
      'reference' => reference,
      'soft_deleted_at' => '2026-02-11T09:00:00.000Z',
      'reason' => 'retention_rule',
      'deleted_by' => 'system_automated'
    }
  end

  describe '.call' do
    subject(:call) { described_class.call(id: message_id, data: data) }

    context 'when the application has not been soft deleted before' do
      it 'publishes a Deleting::SoftDeleted event' do
        expect { call }.to change {
          event_store.read.of_type([Deleting::SoftDeleted]).count
        }.by(1)
      end

      it 'includes the correct data in the event' do
        call

        event = event_store.read.of_type([Deleting::SoftDeleted]).last
        expect(event.data).to include(
          reference: reference,
          soft_deleted_at: '2026-02-11T09:00:00.000Z',
          reason: 'retention_rule',
          deleted_by: 'system_automated'
        )
      end
    end

    context 'when the application has already been soft deleted' do
      before do
        event = Deleting::SoftDeleted.new(
          data: {
            reference: reference,
            soft_deleted_at: '2026-01-01T09:00:00.000Z',
            reason: 'retention_rule',
            deleted_by: 'system_automated'
          }
        )
        event_store.publish(event)
        event_store.link(event.event_id, stream_name: ReferenceHistory.stream_name(reference))
        allow(Rails.logger).to receive(:warn)
      end

      it 'does not publish another Deleting::SoftDeleted event' do
        expect { call }.not_to(change do
          event_store.read.of_type([Deleting::SoftDeleted]).count
        end)
      end

      it 'logs a warning' do
        call
        expect(Rails.logger).to have_received(:warn).with('Application already soft deleted')
      end
    end

    context 'when a different application has been soft deleted' do
      let(:other_reference) { 99_999_999 }

      before do
        event = Deleting::SoftDeleted.new(
          data: {
            reference: other_reference,
            soft_deleted_at: '2026-01-01T09:00:00.000Z',
            reason: 'retention_rule',
            deleted_by: 'system_automated'
          }
        )
        event_store.publish(event)
        event_store.link(event.event_id, stream_name: ReferenceHistory.stream_name(other_reference))
      end

      it 'publishes a Deleting::SoftDeleted event for the new application' do
        expect { call }.to change {
          event_store.read.of_type([Deleting::SoftDeleted]).count
        }.by(1)
      end
    end
  end
end
