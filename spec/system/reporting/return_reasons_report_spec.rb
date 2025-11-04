require 'rails_helper'

RSpec.describe 'Return Reasons Report' do
  include_context 'with stubbed search'

  before do
    caseworker_id = SecureRandom.uuid
    allow(Review).to receive(:reviewer_id_for).with(resource_id) { caseworker_id }
    allow(User).to receive(:name_for).with(caseworker_id).and_return('Joe Case')
  end

  include_context 'when viewing a temporal report'

  let(:report_type) { Types::TemporalReportType['return_reasons_report'] }
  let(:interval) { Types::TemporalInterval['weekly'] }
  let(:period) { '2023-1' }
  let(:resource_id) { SecureRandom.uuid }
  let(:means_passport) { ['on_benefit_check'] }

  let(:stubbed_search_results) do
    [
      {
        resource_id: resource_id,
        reviewed_at: Time.new(2023, 1, 5, 9, 0).utc,
        applicant_name: 'Jo Bloggs',
        reference: 12_345_678,
        return_reason: 'clarification_required',
        return_details: 'More information please.',
        office_code: '1A2BC3D',
        provider_name: 'Andy Others',
        means_passport: means_passport
      }
    ]
  end

  it 'shows the report\'s title' do
    heading_text = page.first('h1').text
    expect(heading_text).to eq('Return reasons report')
  end

  it 'shows the report\'s period name' do
    heading_text = page.first('h2').text
    expect(heading_text).to eq('Week 1, 2023')
  end

  it 'shows the report\'s period range' do
    heading_text = page.first('h2 + h3').text
    expect(heading_text).to eq('Monday 2 January to Sunday 8 January 2023')
  end

  it 'shows the correct column headers' do # rubocop:disable RSpec/ExampleLength
    expected_headers = [
      'Means',
      'Closed by',
      'Date returned',
      'Return reason',
      'LAA reference',
      'Office code',
      'Legal representative'
    ]

    page.all('table thead tr th').each_with_index do |el, i|
      expect(el).to have_content expected_headers[i]
    end
  end

  it 'includes the expected data' do # rubocop:disable RSpec/ExampleLength
    expected_data = [
      'Passported',
      'Joe Case',
      '5 Jan 2023',
      'Clarification required',
      '12345678',
      '1A2BC3D',
      'Andy Others'
    ]

    within first('tbody tr') do
      all('td').each_with_index do |cell, i|
        expect(cell).to have_content expected_data[i]
      end
    end
  end

  context 'when application is non means tested' do
    let(:means_passport) { ['on_not_means_tested'] }

    it 'includes the expected data' do # rubocop:disable RSpec/ExampleLength
      expected_data = [
        'Non means tested',
        'Joe Case',
        '5 Jan 2023',
        'Clarification required',
        '12345678',
        '1A2BC3D',
        'Andy Others'
      ]

      within first('tbody tr') do
        all('td').each_with_index do |cell, i|
          expect(cell).to have_content expected_data[i]
        end
      end
    end
  end

  context 'when application is missing a means passport' do
    let(:means_passport) { [] }

    it 'includes the expected data' do # rubocop:disable RSpec/ExampleLength
      expected_data = [
        'Undetermined',
        'Joe Case',
        '5 Jan 2023',
        'Clarification required',
        '12345678',
        '1A2BC3D',
        'Andy Others'
      ]

      within first('tbody tr') do
        all('td').each_with_index do |cell, i|
          expect(cell).to have_content expected_data[i]
        end
      end
    end
  end

  it_behaves_like 'a table with sortable headers' do
    let(:active_sort_headers) { ['Date returned'] }
    let(:active_sort_direction) { 'ascending' }
    let(:inactive_sort_headers) { ['Return reason', 'LAA reference', 'Office code'] }
  end

  it 'can navigate to the monthly view' do
    expect { click_link('Monthly') }.to change { current_path }
      .from('/reporting/return_reasons_report/weekly/2023-1')
      .to('/reporting/return_reasons_report/monthly/2022-December')

    expect(page).to have_http_status :ok
  end

  it 'can navigate to the weekly view' do
    expect { click_link('Weekly') }.to change { current_path }
      .from('/reporting/return_reasons_report/weekly/2023-1')
      .to('/reporting/return_reasons_report/weekly/2022-52')

    expect(page).to have_http_status :ok
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe 'attempting to download a report' do
    before do
      click_link('Monthly')
    end

    context 'when user is a Data Analysts' do
      let(:current_user_role) { Types::UserRole['data_analyst'] }

      before do
        click_link('Download source data (CSV) 1 of 1')
      end

      it 'can download the source data as a csv' do
        expect(page.driver.response.content_type).to eq 'text/csv; charset=utf-8'
      end

      it 'has the correct csv headers' do
        expect(page.driver.response.body).to match(
          'resource_id,reviewed_at,applicant_name,reference,return_reason,return_details,office_code,provider_name'
        )
      end

      it 'has the correct file name' do
        expect(page.driver.response.headers['Content-Disposition']).to match(
          'return_reasons_report_monthly_2022-December_1_of_1.csv'
        )
      end

      it 'can visit the download link to get the report' do
        visit('/reporting/return_reasons_report/monthly/2023-November/download')
        expect(page.driver.response.headers['Content-Disposition']).to match(
          'return_reasons_report_monthly_2023-November_1_of_1.csv'
        )
      end
    end

    context 'when user is a supervisor' do
      let(:current_user_role) { Types::UserRole['supervisor'] }

      it 'does not show the download link' do
        expect(page).to have_no_content('Download')
      end

      it 'cannot visit the download link to get the report' do
        visit('/reporting/return_reasons_report/monthly/2023-November/download')
        expect(page).to have_http_status :forbidden
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
