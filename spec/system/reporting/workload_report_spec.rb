require 'rails_helper'

RSpec.describe 'Workload Report' do
  before do
    visit '/'
    visit report_path(:workload_report)
  end

  it 'shows the correct column headers' do
    expected_column_headers = 'Business days since applications ' \
                              'were received Applications received Applications still open'
    within('table thead tr') do
      expect(page).to have_content expected_column_headers
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
      expect(page).to have_content 'Between 3 and 9 days'
    end
  end
end
