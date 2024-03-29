require 'rails_helper'

RSpec.describe 'Current Workload Report' do
  include_context 'with many other reviews'

  let(:params) { {} }

  before do
    travel_to Time.zone.local(2023, 11, 28, 12)

    insert_review_events([
                           { business_day: '2023-11-15' },
                           { business_day: '2023-11-16' },
                           { business_day: '2023-11-16', work_stream: 'extradition' },
                           { business_day: '2023-11-23' },
                           { business_day: '2023-11-27' },
                           { business_day: '2023-11-27', state: 'sent_back' },
                           { business_day: '2023-11-27', state: 'completed' },
                           { business_day: '2023-11-28' },
                         ])

    visit '/'
    visit reporting_user_report_path(:current_workload_report, **params)
  end

  it 'shows the correct column headers' do
    expected_headers = ['Business days since applications were received',
                        'Applications received', 'Applications still open']

    page.all('table thead tr th').each_with_index do |el, i|
      expect(el).to have_content expected_headers[i]
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

  it 'shows the correct row headers for three days' do
    within all('table tbody th')[3] do
      expect(page).to have_content '3 days'
    end
  end

  it 'shows the correct row headers for the last row' do
    within all('table tbody th')[4] do
      expect(page).to have_content 'Between 4 and 9 days'
    end
  end

  context 'when viewing by work stream' do
    let(:params) { { work_streams: ['cat_1'] } }

    it 'shows the correct data for applications received column' do
      applications_received_column = all('table tbody tr > td:nth-child(2)').map(&:text)
      expect(applications_received_column).to have_content %w[1 3 0 1 2]
    end

    it 'shows the correct data for applications still open column' do
      applications_open_column = all('table tbody tr > td:nth-child(3)').map(&:text)
      expect(applications_open_column).to have_content %w[1 1 0 1 2]
    end

    context 'when viewing by extradition work stream' do
      let(:params) { { work_streams: ['extradition'] } }

      it 'shows the correct data for applications received column' do
        applications_received_column = all('table tbody tr > td:nth-child(2)').map(&:text)
        expect(applications_received_column).to have_content %w[0 0 0 0 1]
      end

      it 'shows the correct data for applications still open column' do
        applications_open_column = all('table tbody tr > td:nth-child(3)').map(&:text)
        expect(applications_open_column).to have_content %w[0 0 0 0 1]
      end
    end
  end
end
