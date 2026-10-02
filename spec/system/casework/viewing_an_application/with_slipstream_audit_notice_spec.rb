require 'rails_helper'

RSpec.describe 'Slipstream audit notification banner' do
  include_context 'with stubbed application'

  let(:notice_text) do
    'For assurance purposes, Interests of Justice (IOJ) reasons are required for this application.'
  end

  context 'when the application has a confirmed slipstream audit selection' do
    let(:application_data) do
      super().merge(
        'slipstream_audit_selection_outcome' => {
          'status' => 'confirmed',
          'sample_rate' => 10,
          'sampled_at' => '2026-09-03T10:00:00.000Z',
          'status_determined_at' => '2026-09-04T11:00:00.000Z',
          'selection_reason' => 'age'
        }
      )
    end

    it 'shows the banner on the application page' do
      visit crime_application_path(application_id)

      within('.govuk-notification-banner') do
        expect(page).to have_content('Important')
        expect(page).to have_content(notice_text)
      end
    end

    it 'shows the banner on the application history page' do
      visit history_crime_application_path(application_id)

      expect(page).to have_content(notice_text)
    end

    it 'shows the banner on the supporting evidence page' do
      visit crime_application_documents_path(application_id)

      expect(page).to have_content(notice_text)
    end
  end

  context 'when the selection outcome is not confirmed' do
    let(:application_data) do
      super().merge(
        'slipstream_audit_selection_outcome' => {
          'status' => 'withdrawn',
          'sample_rate' => 10,
          'sampled_at' => '2026-09-03T10:00:00.000Z',
          'status_determined_at' => '2026-09-04T11:00:00.000Z',
          'selection_reason' => 'offence'
        }
      )
    end

    it 'does not show the banner' do
      visit crime_application_path(application_id)

      expect(page).to have_no_content(notice_text)
    end
  end

  context 'when there is no selection outcome' do
    let(:application_data) do
      super().except('slipstream_audit_selection_outcome')
    end

    it 'does not show the banner' do
      visit crime_application_path(application_id)

      expect(page).to have_no_content(notice_text)
    end
  end
end
