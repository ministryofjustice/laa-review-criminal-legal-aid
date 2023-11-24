require 'rails_helper'

RSpec.describe 'Return Reasons Report' do
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

  let(:stubbed_search_results) do
    [
      {
        resource_id: resource_id,
        reviewed_at: Time.new(2023, 1, 5, 9, 0).utc,
        appplicant_name: 'Jo Bloggs',
        reference: 12_345_678,
        return_reason: 'clarification_required',
        return_details: 'More information please.',
        office_code: '1A2BC3D',
        provider_name: 'Andy Others'
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
    expect(heading_text).to eq('Monday 2 January 2023 — Sunday 8 January 2023')
  end

  it 'shows the correct column headers' do # rubocop:disable RSpec/ExampleLength
    expected_headers = [
      'Means',
      'Closed by',
      'Date returned',
      'Return reason',
      'Return details',
      'Reference number',
      'Office code',
      'Legal representative'
    ]

    page.all('table thead tr th').each_with_index do |el, i|
      expect(el).to have_content expected_headers[i]
    end
  end

  it 'includes the expected data' do # rubocop:disable RSpec/ExampleLength
    expected_data = [
      'passported',
      'Joe Case',
      '5 Jan 2023',
      'clarification required',
      'More information please',
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

  it_behaves_like 'a table with sortable headers' do
    let(:active_sort_headers) { ['Date returned'] }
    let(:active_sort_direction) { 'ascending' }
    let(:inactive_sort_headers) { ['Return reason', 'Reference number', 'Office code'] }
  end

  it 'can navigate to the monthly view' do
    expect { click_link('Monthly') }.to change { current_path }
      .from('/reporting/return_reasons_report/weekly/2023-1')
      .to('/reporting/return_reasons_report/monthly/now')

    expect(page).to have_http_status :ok
  end

  it 'can navigate to the weekly view' do
    expect { click_link('Weekly') }.to change { current_path }
      .from('/reporting/return_reasons_report/weekly/2023-1')
      .to('/reporting/return_reasons_report/weekly/now')

    expect(page).to have_http_status :ok
  end
end
