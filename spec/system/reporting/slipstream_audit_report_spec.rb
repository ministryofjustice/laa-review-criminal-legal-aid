require 'rails_helper'

RSpec.describe 'Slipstream Audit Report' do
  let(:report_title) { 'Slipstream audit report' }
  let(:download_link) { 'Download source data (CSV) 1 of 1' }
  let(:complete_report_path) { 'reporting/slipstream_audit_report/monthly/2025-October' }

  let(:datastore_response) do
    {
      'data' => [
        {
          'reference' => 6_000_001,
          'office_code' => '1A2B3C',
          'application_type' => 'initial',
          'offences' => [
            { 'name' => 'Theft', 'offence_class' => 'C', 'slipstreamable' => true }
          ],
          'status' => 'confirmed',
          'sample_rate' => 20,
          'sampled_at' => '2025-10-02T09:00:00Z',
          'status_determined_at' => '2025-10-02T09:05:00Z',
          'submitted_at' => '2025-10-01T08:00:00Z',
          'maat_reference' => 1_234_567,
          'ioj_outcome' => 'passed'
        },
        {
          'reference' => 6_000_002,
          'office_code' => '2B3C4D',
          'application_type' => 'post_submission_evidence',
          'offences' => [
            { 'name' => 'Burglary', 'offence_class' => 'B', 'slipstreamable' => false }
          ],
          'status' => 'confirmed',
          'sample_rate' => 20,
          'sampled_at' => '2025-10-15T09:00:00Z',
          'status_determined_at' => '2025-10-15T09:05:00Z',
          'submitted_at' => '2025-10-14T08:00:00Z',
          'maat_reference' => nil,
          'ioj_outcome' => nil
        }
      ],
      'offence_sampling' => [
        { 'offence' => 'Theft', 'confirmed_applications' => 1 },
        { 'offence' => 'Burglary', 'confirmed_applications' => 1 }
      ]
    }
  end

  before do
    stub_request(
      :get,
      'https://datastore-api-stub.test/api/v1/reporting/slipstream_audit/monthly/2025-October'
    ).to_return_json(body: datastore_response)

    visit '/reporting'
  end

  context 'when a Business Support user' do
    let(:current_user_role) { UserRole::BUSINESS_SUPPORT }

    it 'shows a link on the user reports page' do
      expect(page).to have_link report_title
    end

    describe 'attempts to directly view the report' do
      before { visit complete_report_path }

      it 'returns the reports page' do
        expect(page).to have_http_status(:success)
        expect(page).to have_link('Monthly')
      end

      it 'does not show the Weekly or Daily tabs' do
        expect(page).not_to have_link('Daily')
        expect(page).not_to have_link('Weekly')
      end

      it 'shows the correct column headers' do # rubocop:disable RSpec/ExampleLength
        expected_headers = [
          'LAA reference',
          'Office account number',
          'Application type',
          'Offences',
          'Status',
          'Sample rate',
          'Sampled at',
          'Status determined at',
          'Date received',
          'MAAT reference',
          'IoJ outcome'
        ]

        page.all('table thead tr th').each_with_index do |el, i|
          expect(el).to have_content expected_headers[i]
        end
      end

      it 'shows the expected row data, including undetermined values' do # rubocop:disable RSpec/MultipleExpectations
        within all('tbody tr').last do
          expect(page).to have_content('6000002')
          expect(page).to have_content('Burglary')
          expect(page).to have_content('Not yet determined')
        end
      end

      it 'shows the applications selected count' do
        expect(page).to have_content('2 applications were selected for slipstream audit.')
      end

      it_behaves_like 'a table with sortable headers' do
        let(:active_sort_headers) { ['Date received'] }
        let(:active_sort_direction) { 'ascending' }
        let(:inactive_sort_headers) do
          ['Office account number', 'Application type', 'Status', 'Sampled at', 'IoJ outcome']
        end
      end

      describe 'filtering by offence' do
        before do
          select 'Burglary', from: 'filter-offence-field'
          click_button 'Filter'
        end

        it 'shows only applications with the selected offence' do
          expect(page).to have_content('6000002')
          expect(page).not_to have_content('6000001')
        end

        it 'shows a link to clear the filter' do
          expect(page).to have_link('Show all offences')
        end
      end

      describe 'downloading the report' do
        before { click_link download_link }

        it 'has the correct content type' do
          expect(page.driver.response.content_type).to eq('text/csv; charset=utf-8')
        end

        it 'includes the expected data' do
          expect(page.driver.response.body).to include('6000001', '6000002', 'Theft', 'Burglary')
        end

        it 'has the correct file name' do
          expect(page.driver.response.headers['Content-Disposition']).to match(
            'slipstream_audit_report_monthly_2025-October_1_of_1.csv'
          )
        end
      end
    end
  end

  context 'when a supervisor' do
    let(:current_user_role) { UserRole::SUPERVISOR }

    it 'does not show a link on the user reports page' do
      expect(page).not_to have_link report_title
    end

    describe 'attempts to directly view the report' do
      before { visit complete_report_path }

      it 'returns a forbidden error' do
        expect(page).to have_http_status(:forbidden)
      end
    end
  end

  context 'when a Data Analyst' do
    let(:current_user_role) { UserRole::DATA_ANALYST }

    it 'does not show a link on the user reports page' do
      expect(page).not_to have_link report_title
    end

    describe 'attempts to directly view the report' do
      before { visit complete_report_path }

      it 'returns a forbidden error' do
        expect(page).to have_http_status(:forbidden)
      end
    end
  end
end
