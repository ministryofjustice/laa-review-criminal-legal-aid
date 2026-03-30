require 'rails_helper'

RSpec.describe Deleting do
  let(:reference) { 12_345_678 }
  let(:application_id) { SecureRandom.uuid }
  let(:event_store) { Rails.configuration.event_store }

  describe '.already_archived?' do
    context 'when no Deleting::Archived event exists for the reference' do
      it 'returns false' do
        expect(described_class.already_archived?(reference)).to be false
      end
    end

    context 'when a Deleting::Archived event exists for the reference' do
      before do
        event = Deleting::Archived.new(
          data: {
            application_id: application_id,
            application_type: 'initial',
            reference: reference,
            archived_at: Time.current.iso8601
          }
        )
        event_store.publish(event)
        event_store.link(event.event_id, stream_name: ReferenceHistory.stream_name(reference))
      end

      it 'returns true' do
        expect(described_class.already_archived?(reference)).to be true
      end
    end

    context 'when a Deleting::Archived event exists for a different reference' do
      let(:other_reference) { 99_999_999 }

      before do
        event = Deleting::Archived.new(
          data: {
            application_id: application_id,
            application_type: 'initial',
            reference: other_reference,
            archived_at: Time.current.iso8601
          }
        )
        event_store.publish(event)
        event_store.link(event.event_id, stream_name: ReferenceHistory.stream_name(other_reference))
      end

      it 'returns false' do
        expect(described_class.already_archived?(reference)).to be false
      end
    end
  end

  describe '.already_soft_deleted?' do
    context 'when no Deleting::SoftDeleted event exists for the reference' do
      it 'returns false' do
        expect(described_class.already_soft_deleted?(reference)).to be false
      end
    end

    context 'when a Deleting::SoftDeleted event exists for the reference' do
      before do
        event = Deleting::SoftDeleted.new(
          data: {
            reference: reference,
            soft_deleted_at: Time.current.iso8601,
            reason: 'retention_rule',
            deleted_by: 'system_automated'
          }
        )
        event_store.publish(event)
        event_store.link(event.event_id, stream_name: ReferenceHistory.stream_name(reference))
      end

      it 'returns true' do
        expect(described_class.already_soft_deleted?(reference)).to be true
      end
    end

    context 'when a Deleting::SoftDeleted event exists for a different reference' do
      let(:other_reference) { 99_999_999 }

      before do
        event = Deleting::SoftDeleted.new(
          data: {
            reference: other_reference,
            soft_deleted_at: Time.current.iso8601,
            reason: 'retention_rule',
            deleted_by: 'system_automated'
          }
        )
        event_store.publish(event)
        event_store.link(event.event_id, stream_name: ReferenceHistory.stream_name(other_reference))
      end

      it 'returns false' do
        expect(described_class.already_soft_deleted?(reference)).to be false
      end
    end
  end
end
