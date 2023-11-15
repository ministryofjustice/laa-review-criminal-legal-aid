require 'rails_helper'

RSpec.describe 'Volumes Report' do
  include_context 'when viewing a temporal report'

  let(:report_type) { Types::TemporalReportType['volumes_report'] }
  let(:interval) { Types::TemporalInterval['daily'] }
  let(:period) { '2023-01-01' }

  it 'shows the report\'s title' do
    heading_text = page.first('h1').text
    expect(heading_text).to eq('Volumes report')
  end

  it 'shows the report\'s period name' do
    heading_text = page.first('h2').text
    expect(heading_text).to eq('Sunday 1 January 2023')
  end

  it 'shows data for CAT 3' do
    within all('table tbody tr td')[0] do
      expect(page).to have_content 'CAT 3'
    end
  end

  it 'shows the correct column headers' do
    expected_headers = %w[Type Received Closed]

    page.all('table thead tr th').each_with_index do |el, i|
      expect(el).to have_content expected_headers[i]
    end
  end

  it 'shows the number closed' do
    number_closed = 1

    within all('table tbody tr td')[1] do
      expect(page).to have_content number_closed
    end
  end

  it 'shows the number received' do
    number_received = 0
    within all('table tbody tr td')[2] do
      expect(page).to have_content number_received
    end
  end

  it 'can navigate to the monthly view' do
    expect { click_link('Monthly') }.to change { current_path }
      .from('/reporting/volumes_report/daily/2023-01-01')
      .to('/reporting/volumes_report/monthly/now')

    expect(page).to have_http_status :ok
  end

  it 'can navigate to the weekly view' do
    expect { click_link('Weekly') }.to change { current_path }
      .from('/reporting/volumes_report/daily/2023-01-01')
      .to('/reporting/volumes_report/weekly/now')

    expect(page).to have_http_status :ok
  end

  it 'can navigate to the latest daily view' do
    expect { click_link('Daily') }.to change { current_path }
      .from('/reporting/volumes_report/daily/2023-01-01')
      .to('/reporting/volumes_report/daily/now')

    expect(page).to have_http_status :ok
  end
end
