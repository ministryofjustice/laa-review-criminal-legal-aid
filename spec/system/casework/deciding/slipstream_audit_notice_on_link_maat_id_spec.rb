require 'rails_helper'

RSpec.describe 'Slipstream audit notification banner on the Link MAAT ID page' do
  include DecisionFormHelpers

  include_context 'with stubbed application'

  let(:notice_text) { 'This application requires an IOJ test.' }
  let(:slipstream_audit_enabled) { true }
  let(:status) { 'confirmed' }
  let(:mock_get_decision) { instance_double(Maat::GetDecision) }

  let(:application_data) do
    JSON.parse(LaaCrimeSchemas.fixture(1.0).read).merge(
      'slipstream_audit_selection_outcome' => {
        'status' => status,
        'sample_rate' => 10,
        'sampled_at' => '2026-09-03T10:00:00.000Z',
        'status_determined_at' => '2026-09-04T11:00:00.000Z',
        'selection_reason' => 'age'
      }
    )
  end

  before do
    allow(FeatureFlags).to receive(:slipstream_audit).and_return(
      instance_double(FeatureFlags::EnabledFeature, enabled?: slipstream_audit_enabled)
    )

    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
      .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

    allow(mock_get_decision).to receive(:by_usn!).and_raise(Maat::RecordNotFound)
    allow(Maat::GetDecision).to receive(:new).and_return(mock_get_decision)

    visit crime_application_path(application_id)
    click_button 'Assign to your list'
    click_button 'Mark as ready for MAAT'
  end

  context 'when the application has a confirmed slipstream audit selection' do
    it 'shows the banner when visiting the page directly' do
      visit crime_application_link_maat_id_path(application_id)

      within('.moj-alert--warning#slipstream-audit-notice') do
        expect(page).to have_css('h2.moj-alert__heading', text: 'Slipstream audit')
        expect(page).to have_content(notice_text)
      end
    end

    it 'shows the banner alongside the flash when the MAAT record is not found' do
      click_button 'Add funding decision from MAAT'

      expect(page).to have_notification_banner(
        text: 'No MAAT ID found that links to LAA reference number 6000001'
      )
      expect(page).to have_css('.moj-alert--warning', text: notice_text)
    end

    it 'shows the banner alongside the error summary when the MAAT ID is invalid' do
      visit crime_application_link_maat_id_path(application_id)
      save_and_continue

      expect(page).to have_error('MAAT ID', 'Enter a valid MAAT ID')
      expect(page).to have_css('.moj-alert--warning', text: notice_text)
    end
  end

  context 'when the selection outcome is not confirmed' do
    let(:status) { 'withdrawn' }

    it 'does not show the banner' do
      visit crime_application_link_maat_id_path(application_id)

      expect(page).to have_no_content(notice_text)
    end
  end

  context 'when the slipstream_audit feature flag is disabled' do
    let(:slipstream_audit_enabled) { false }

    it 'does not show the banner' do
      visit crime_application_link_maat_id_path(application_id)

      expect(page).to have_no_content(notice_text)
    end
  end
end
