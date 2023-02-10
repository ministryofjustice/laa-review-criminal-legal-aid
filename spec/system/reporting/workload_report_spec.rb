require 'rails_helper'

RSpec.describe 'Workload Report' do
  before do
    visit '/'
    visit report_path(:workload_report)
  end

  it 'shows the correct column headers' do
    within('table thead tr') do
      expect(page).to have_content 'Days passed Open applications Closed applications'
    end
  end

  it 'shows the correct row headers for day zero' do
    within all('table tbody th')[0] do
      expect(page).to have_content '0 days'
    end
  end

  it 'shows the correct row header for one day' do
    within all('table tbody th')[1] do
      expect(page).to have_content '1 day'
    end
  end

  it 'shows the correct row headers for two days' do
    within all('table tbody th')[2] do
      expect(page).to have_content '2 days'
    end
  end

  it 'shows the correct row headers for the last row' do
    within all('table tbody th')[3] do
      expect(page).to have_content '3 or more days'
    end
  end
end
