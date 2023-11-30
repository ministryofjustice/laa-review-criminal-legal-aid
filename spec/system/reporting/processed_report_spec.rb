require 'rails_helper'

RSpec.describe 'Processed Report' do
  before do
    visit '/'
    visit reporting_user_report_path(:processed_report)
  end

  it 'shows the correct column headers' do
    expected_headers = [
      'When applications were closed', 'Number of closed applications'
    ]

    page.all('table thead tr th').each_with_index do |el, i|
      expect(el).to have_content expected_headers[i]
    end
  end

  it 'shows the correct row headers today' do
    within all('table tbody th')[0] do
      expect(page).to have_content 'Today'
    end
  end

  it 'shows the correct row headers yesterday' do
    within all('table tbody th')[1] do
      expect(page).to have_content 'Yesterday'
    end
  end

  it 'shows the correct row headers the day before yesterday' do
    within all('table tbody th')[2] do
      expect(page).to have_content 'Day before yesterday'
    end
  end
end