require 'rails_helper'

RSpec.describe 'Workload Report' do
  let(:current_user_role) { UserRole::DATA_ANALYST }

  before do
    visit '/'

    travel_to Time.zone.local(2023, 11, 28, 23, 59)
    visit reporting_current_snapshot_path(:workload_report)
  end

  it 'shows the correct detail column headers' do
    expected_headers = ['', 'Received', 'Closed', '0 days', '1 day', '2 days', '3 days', '4-9 days', 'Total']

    within('#cat-1') do
      page.all('table thead tr.colgroup-details th').each_with_index do |el, i|
        expect(el).to have_content expected_headers[i]
      end
    end
  end

  it 'shows the expected caption' do # rubocop:disable RSpec/ExampleLength
    expected_captions = [
      'CAT 1 workload',
      'CAT 2 workload',
      'Extradition workload',
      'Non-means workload',
    ]

    page.all('table caption').each_with_index do |el, i|
      expect(el).to have_content expected_captions[i]
    end
  end

  it 'shows the expected colgroup headers' do
    expected_headers = ['', 'From 00:00 until 23:59',
                        'Applications still open by age in business days at 23:59']

    within('#cat-1') do
      page.all('table thead tr.colgroup-headers th').each_with_index do |el, i|
        expect(el).to have_content expected_headers[i]
      end
    end
  end

  it 'has the heading "Workload report"' do
    expect(page.find('h1')).to have_text 'Workload report'
  end

  it 'has the page title "Workload report"' do
    expect(page.title).to have_text 'Workload report'
  end

  it 'shows the correct row headers for each work stream' do
    within('#cat-1') do
      column = all('table tbody tr th:first-child').map(&:text)
      expect(column).to eq ['Initial application', 'Post submission evidence', 'Change in financial circumstances',
                            'Total']
    end
  end
end
