require 'rails_helper'

RSpec.describe 'Viewing an application that has been deleted' do
  include_context 'with a deleted application'

  shared_examples 'deleted application display' do
    before do
      visit crime_application_path(application_id)
    end

    it 'replaces the review status with "Personal data deleted"' do
      within('.govuk-tag--grey') do
        expect(page).to have_text('Personal data deleted')
      end
    end

    it 'includes the page title' do
      expect(page).to have_content I18n.t('casework.crime_applications.show.page_title')
    end

    describe 'applications details' do
      it 'shows relevant details' do # rubocop:disable RSpec/MultipleExpectations
        within(summary_card('Overview')) do |card|
          expect(card).to have_summary_row 'Application type', 'Initial application'
          expect(card).to have_summary_row 'Date stamp', '24/10/2022'
          expect(card).to have_summary_row 'Date submitted', '24/10/2022'
          expect(card).to have_summary_row 'Office account number', '1A123B'
        end
      end
    end
  end

  context 'when reference_history feature flag is disabled' do
    before do
      allow(FeatureFlags).to receive(:reference_history) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: false)
      }
    end

    it_behaves_like 'deleted application display'

    describe 'applications history' do
      before do
        visit crime_application_path(application_id)
        click_link 'Application history'
      end

      it 'shows the deletion event at the top of the application history' do
        expect(page.first('.app-dashboard-table tbody tr').text).to match(
          'System Personal data deleted in accordance with data retention policy'
        )
      end
    end
  end

  context 'when reference_history feature flag is enabled' do
    let(:application_reference) { 120_398_120 }
    let(:soft_deleted_at) { 1.week.ago }

    let(:application_data) do
      super().deep_merge('reference' => application_reference)
    end

    before do
      allow(FeatureFlags).to receive(:reference_history) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      }

      Deleting::SoftDeleteApplicationEvent.call(
        id: SecureRandom.uuid,
        data: {
          'reference' => application_reference,
          'soft_deleted_at' => soft_deleted_at.iso8601,
          'reason' => 'data_retention',
          'deleted_by' => 'system'
        }
      )
    end

    it_behaves_like 'deleted application display'

    describe 'applications history' do
      before do
        visit crime_application_path(application_id)
        click_link 'Application history'
      end

      it 'shows the deletion event from the ReferenceHistory stream' do
        expect(page.first('.app-dashboard-table tbody tr').text).to match(
          'System Personal data deleted in accordance with data retention policy'
        )
      end
    end
  end
end
