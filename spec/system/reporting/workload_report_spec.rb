require 'rails_helper'

RSpec.describe 'Workload Report' do
  let(:current_user_role) { UserRole::DATA_ANALYST }

  before do
    visit '/'
    visit reporting_current_snapshot_path(:workload_report)
  end

  it 'shows the correct column headers' do
    expected_headers = ['', 'Received', 'Closed', '0 days', '1 day', '2 days', '3 days', '4-9 days', 'Total']

    page.all('table thead tr.colgroup-details th').each_with_index do |el, i|
      expect(el).to have_content expected_headers[i]
    end
  end

  it 'has the heading "Workload report"' do
    expect(page.find('h1')).to have_text 'Workload report'
  end

  it 'has the page title "Workload report"' do
    expect(page.title).to have_text 'Workload report'
  end

  it 'shows the correct row headers for each work stream' do
    column = all('table tbody tr th:first-child').map(&:text)
    expect(column).to eq ['CAT 1', 'CAT 2', 'Extradition', 'Total']
  end
end
