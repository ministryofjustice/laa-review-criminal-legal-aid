require 'rails_helper'

RSpec.describe 'Processed Report' do
  before do
    visit '/'
    visit report_path(:processed_report)
  end

  it 'shows the correct column headers' do
    within('table thead tr') do
      expect(page).to have_content 'Closed on Closed applications'
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
