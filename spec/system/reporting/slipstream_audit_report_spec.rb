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
          'selection_reason' => 'offence',
          'sample_rate' => 20,
          'sampled_at' => '2025-10-02T09:00:00Z',
          'status_determined_at' => '2025-10-02T09:05:00Z',
          'submitted_at' => '2025-10-01T08:00:00Z',
          'maat_reference' => 1_234_567,
          'ioj_outcome' => 'passed'
        },
        {
          'reference' => 6_000_099,
          'office_code' => '9Z9Z9Z',
          'application_type' => 'initial',
          'offences' => [
            { 'name' => 'Theft', 'offence_class' => 'C', 'slipstreamable' => true }
          ],
          'status' => 'confirmed',
          'selection_reason' => 'offence',
          'sample_rate' => 20,
          'sampled_at' => '2025-10-10T09:00:00Z',
          'status_determined_at' => '2025-10-10T09:05:00Z',
          'submitted_at' => '2025-10-09T08:00:00Z',
          'maat_reference' => nil,
          'ioj_outcome' => nil
        },
        {
          'reference' => 6_000_002,
          'office_code' => '2B3C4D',
          'application_type' => 'initial',
          'offences' => [
            { 'name' => 'Burglary', 'offence_class' => 'B', 'slipstreamable' => false }
          ],
          'status' => 'confirmed',
          'selection_reason' => nil,
          'sample_rate' => 20,
          'sampled_at' => '2025-10-15T09:00:00Z',
          'status_determined_at' => '2025-10-15T09:05:00Z',
          'submitted_at' => '2025-10-14T08:00:00Z',
          'maat_reference' => 2_345_678,
          'ioj_outcome' => 'failed'
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
          'Offences',
          'Sampled at',
          'Date received',
          'MAAT reference',
          'IoJ outcome',
          'Selection reason'
        ]

        expect(page.all('table thead tr th').map(&:text)).to eq(expected_headers)
      end

      it 'shows the expected row data' do # rubocop:disable RSpec/MultipleExpectations
        within all('tbody tr').last do
          expect(page).to have_content('6000002')
          expect(page).to have_content('Burglary')
          expect(page).to have_content('2345678')
          expect(page).to have_content('Failed')
        end
      end

      it 'excludes applications without a MAAT reference and IoJ outcome' do
        expect(all('tbody tr').map { |row| row.first('td').text }).to eq(%w[6000001 6000002])
      end

      it 'shows the selection reason' do
        expect(all('tbody tr').first.all('td')[7]).to have_text('Offence', exact: true)
        expect(all('tbody tr').last.all('td')[7]).to have_text('Not yet determined', exact: true)
      end

      it 'shows the applications selected count' do
        expect(page).to have_content('2 applications were selected for slipstream audit.')
      end

      it_behaves_like 'a table with sortable headers' do
        let(:active_sort_headers) { ['Date received'] }
        let(:active_sort_direction) { 'ascending' }
        let(:inactive_sort_headers) do
          ['Office account number', 'Sampled at', 'IoJ outcome', 'Selection reason']
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
          expect(page).to have_link('Clear filters')
        end
      end

      describe 'filtering by selection reason' do
        before do
          select 'Offence', from: 'filter-selection-reason-field'
          click_button 'Filter'
        end

        it 'shows only applications with the selected selection reason' do
          expect(page).to have_content('6000001')
          expect(page).not_to have_content('6000002')
        end

        it 'shows a link to clear the filter' do
          expect(page).to have_link('Clear filters')
        end

        it 'keeps the selection reason filter in sort links' do
          click_link 'Office account number'
          expect(page).to have_content('6000001')
          expect(page).not_to have_content('6000002')
        end
      end

      describe 'filtering by offence and selection reason' do
        before do
          datastore_response['data'] << datastore_response['data'].last.merge(
            'reference' => 6_000_003, 'selection_reason' => 'age'
          )
          datastore_response['data'] << datastore_response['data'].first.merge(
            'reference' => 6_000_004, 'selection_reason' => 'age'
          )
          stub_request(:get, %r{/reporting/slipstream_audit/monthly/2025-October})
            .to_return_json(body: datastore_response)
          select 'Burglary', from: 'filter-offence-field'
          select 'Age', from: 'filter-selection-reason-field'
          click_button 'Filter'
        end

        it 'shows only applications matching both filters' do
          expect(all('tbody tr').map { |row| row.first('td').text }).to eq(%w[6000003])
        end

        it 'exports only applications matching both filters' do
          click_link download_link
          expect(CSV.parse(page.body, headers: true).pluck('reference')).to eq(%w[6000003])
        end
      end

      describe 'downloading the report' do
        before { click_link download_link }

        it 'has the correct content type' do
          expect(page.driver.response.content_type).to eq('text/csv; charset=utf-8')
        end

        it 'includes the expected data' do
          expect(page.driver.response.body).to include('6000001', '6000002', 'Theft', 'Burglary')
          expect(page.driver.response.body).not_to include('6000099')
        end

        it 'has the confirmed columns in the displayed order' do
          expect(CSV.parse(page.driver.response.body, headers: true).headers).to eq(
            %w[reference office_code offences sample_rate sampled_at submitted_at maat_reference ioj_outcome
               selection_reason]
          )
        end

        it 'includes the selection reason column with raw values' do
          csv = CSV.parse(page.driver.response.body, headers: true)
          expect(csv.headers).to include('selection_reason')
          expect(csv.pluck('selection_reason')).to eq(['offence', nil])
        end

        it 'has the correct file name' do
          expect(page.driver.response.headers['Content-Disposition']).to match(
            'slipstream_audit_report_monthly_2025-October_1_of_1.csv'
          )
        end
      end

      describe 'downloading a filtered and sorted report' do
        before do
          datastore_response['data'] << datastore_response['data'].last.merge(
            'reference' => 6_000_003, 'office_code' => '3C4D5E'
          )
          stub_request(:get, %r{/reporting/slipstream_audit/monthly/2025-October})
            .to_return_json(body: datastore_response)
          select 'Burglary', from: 'filter-offence-field'
          click_button 'Filter'
          click_link 'Office account number'
        end

        it 'exports exactly the displayed rows in the displayed order' do
          expect(all('tbody tr').map { |row| row.first('td').text }).to eq(%w[6000003 6000002])
          click_link download_link
          expect(CSV.parse(page.body, headers: true).pluck('reference')).to eq(%w[6000003 6000002])
        end
      end
    end

    context 'with JavaScript enabled' do
      before do
        driven_by :headless_chrome
        visit '/'
        click_button 'Start now'
        select current_user.email
        click_button 'Sign in'
        find_link('Sign out')
        visit "/#{complete_report_path}"
      end

      it 'supports changing, sorting and clearing offence filters', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        select 'Burglary', from: 'filter-offence-field'
        click_button 'Filter'
        expect(page).to have_content('6000002')
        expect(page).not_to have_content('6000001')

        click_link 'Office account number'
        expect(page).to have_css('th[aria-sort="descending"]', text: 'Office account number')
        expect(page).not_to have_content('6000001')

        select 'Theft', from: 'filter-offence-field'
        click_button 'Filter'
        expect(page).to have_content('6000001')
        expect(page).not_to have_content('6000002')

        select 'All offences', from: 'filter-offence-field'
        click_button 'Filter'
        expect(page).to have_content('6000002')
        expect(page).to have_content('6000001')
        expect(page).to have_css('th[aria-sort="descending"]', text: 'Office account number')

        select 'Burglary', from: 'filter-offence-field'
        click_button 'Filter'
        expect(page).not_to have_content('6000001')
        click_link 'Clear filters'
        expect(page).to have_content('6000001')
        expect(page).to have_content('6000002')
        expect(page).to have_css('th[aria-sort="descending"]', text: 'Office account number')

        select 'Offence', from: 'filter-selection-reason-field'
        click_button 'Filter'
        expect(page).to have_link('Office account number', href: /filter%5Bselection_reason%5D=offence/)
        expect(page).to have_content('6000001')
        expect(page).not_to have_content('6000002')
        expect(page).to have_css('th[aria-sort="descending"]', text: 'Office account number')
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
