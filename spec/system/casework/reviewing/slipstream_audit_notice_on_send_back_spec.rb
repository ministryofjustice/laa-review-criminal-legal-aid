require 'rails_helper'

RSpec.describe 'Slipstream audit notification banner on the Send back to provider page' do
  include_context 'with stubbed application'

  let(:notice_text) { 'This application requires an IOJ test.' }
  let(:slipstream_audit_enabled) { true }
  let(:status) { 'confirmed' }

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

    visit crime_application_path(application_id)
    click_button 'Assign to your list'
    click_link 'Send back to provider'
  end

  context 'when the application has a confirmed slipstream audit selection' do
    it 'shows the banner' do
      within('.moj-alert--warning#slipstream-audit-notice[aria-label="warning: Slipstream audit"]') do
        expect(page).to have_content(notice_text)
      end
    end

    it 'shows the banner when the return details are invalid' do
      click_button 'Send back to provider'

      expect(page).to have_css('.govuk-error-summary')
      expect(page).to have_css('.moj-alert--warning', text: notice_text)
    end
  end

  context 'when the selection outcome is not confirmed' do
    let(:status) { 'withdrawn' }

    it 'does not show the banner' do
      expect(page).to have_no_content(notice_text)
    end
  end

  context 'when the slipstream_audit feature flag is disabled' do
    let(:slipstream_audit_enabled) { false }

    it 'does not show the banner' do
      expect(page).to have_no_content(notice_text)
    end
  end
end
