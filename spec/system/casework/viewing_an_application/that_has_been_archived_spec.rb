require 'rails_helper'

RSpec.describe 'Viewing an application that has been archived' do
  include_context 'with stubbed application'

  context 'when reference_history feature flag is disabled' do
    let(:application_data) do
      super().deep_merge('archived_at' => '2026-02-16T11:52:20.285Z')
    end

    before do
      allow(FeatureFlags).to receive(:reference_history) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: false)
      }
    end

    describe 'applications history' do
      before do
        visit crime_application_path(application_id)
        click_link 'Application history'
      end

      it 'shows the archived event in the application history' do
        first_row = page.first('.app-dashboard-table tbody tr').text
        expect(first_row).to match('Provider Application deleted by provider')
      end
    end
  end

  context 'when reference_history feature flag is enabled' do
    let(:application_reference) { 120_398_120 }

    let(:application_data) do
      super().deep_merge('reference' => application_reference)
    end

    before do
      allow(FeatureFlags).to receive(:reference_history) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      }

      Deleting::ArchiveApplicationEvent.call(
        id: SecureRandom.uuid,
        data: {
          'id' => application_id,
          'reference' => application_reference,
          'archived_at' => 1.week.ago.iso8601,
          'application_type' => 'initial'
        }
      )
    end

    describe 'applications history' do
      before do
        visit crime_application_path(application_id)
        click_link 'Application history'
      end

      it 'shows the archived event from the ReferenceHistory stream' do
        first_row = page.first('.app-dashboard-table tbody tr').text
        expect(first_row).to match('Provider Application deleted by provider')
      end
    end
  end
end
