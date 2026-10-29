require 'rails_helper'

RSpec.describe 'Slipstream audit notification banner' do
  include_context 'with stubbed application'

  let(:notice_text) { 'This application requires an IOJ test.' }

  let(:slipstream_audit_enabled) { true }

  before do
    allow(FeatureFlags).to receive(:slipstream_audit).and_return(
      instance_double(FeatureFlags::EnabledFeature, enabled?: slipstream_audit_enabled)
    )
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

      within('.moj-alert.moj-alert--warning#slipstream-audit-notice[aria-label="warning: Slipstream audit"]') do
        expect(page).to have_no_css('.moj-alert__heading')
        expect(page).to have_content(notice_text)
      end
    end

    it 'does not show the banner as a GOV.UK notification banner' do
      visit crime_application_path(application_id)

      expect(page).to have_no_css('.govuk-notification-banner')
    end

    it 'shows the banner on the application history page' do
      visit history_crime_application_path(application_id)

      expect(page).to have_content(notice_text)
    end

    it 'shows the banner on the supporting evidence page' do
      visit crime_application_documents_path(application_id)

      expect(page).to have_content(notice_text)
    end

    context 'when the slipstream_audit feature flag is disabled' do
      let(:slipstream_audit_enabled) { false }

      it 'does not show the banner' do
        visit crime_application_path(application_id)

        expect(page).to have_no_content(notice_text)
      end
    end
  end

  context 'when the application is post submission evidence' do
    let(:pse_application_id) { '21c37e3e-520f-46f1-bd1f-5c25ffc57d70' }
    let(:pse_application_data) do
      JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'post_submission_evidence').read)
          .merge('parent_id' => application_id)
    end

    before do
      stub_request(
        :get,
        "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{pse_application_id}"
      ).to_return(body: pse_application_data.to_json, status: 200)
    end

    context 'when the parent application has a confirmed slipstream audit selection' do
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
        visit crime_application_path(pse_application_id)

        expect(page).to have_css('.moj-alert--warning#slipstream-audit-notice', text: notice_text)
      end

      it 'shows the banner on the supporting evidence page' do
        visit crime_application_documents_path(pse_application_id)

        expect(page).to have_css('.moj-alert--warning#slipstream-audit-notice', text: notice_text)
      end
    end

    context 'when the parent application has no selection outcome' do
      let(:application_data) do
        super().except('slipstream_audit_selection_outcome')
      end

      it 'does not show the banner on the supporting evidence page' do
        visit crime_application_documents_path(pse_application_id)

        expect(page).to have_no_content(notice_text)
      end
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
