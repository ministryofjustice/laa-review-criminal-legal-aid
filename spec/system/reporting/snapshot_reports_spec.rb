require 'rails_helper'

RSpec.describe 'Snapshot report' do
  include_context 'with an existing application'

  let(:current_user_role) { UserRole::DATA_ANALYST }
  let(:report_type) { Types::SnapshotReportType['workload_report'] }
  let(:previous_day) { 'Previous day' }
  let(:next_day) { 'Next day' }
  let(:yesterday) { Time.current.in_time_zone('London').to_date.yesterday }

  context 'when viwing the current snaphshot for the worklaod report' do
    before do
      visit reporting_current_snapshot_path(report_type)
    end

    it 'has the heading "Workload report"' do
      expect(page.find('h1')).to have_text 'Workload report'
    end

    it 'has the page title "Workload report"' do
      expect(page.title).to have_text 'Workload report'
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

    it 'can navigate to the end of the the previous day' do
      expect { click_link(previous_day) }.to change { current_path }
        .from('/reporting/workload_report/now')
        .to("/reporting/workload_report/#{yesterday}/at/23:59")
    end

    it 'does not show a link to the next day' do
      expect(page).not_to have_link(next_day)
    end

    context 'when the report_type is not supported' do
      let(:report_type) { Types::TemporalReportType['caseworker_report'] }

      it 'shows the page not found' do
        expect(page).to have_http_status(:not_found)
      end
    end
  end

  context 'when viewing a snapshot from the previous day at a specified time' do
    before do
      visit reporting_snapshot_path(report_type: report_type, date: yesterday, time: '12:00')
    end

    it 'can navigate to the end of the next day' do
      expect { click_link(next_day) }.to change { current_path }.to('/reporting/workload_report/now')
    end

    it 'can navigate to the end of the previous day' do
      expect { click_link(previous_day) }.to change { current_path }
        .to("/reporting/workload_report/#{yesterday.yesterday}/at/23:59")
    end

    it 'shows the report at the specified time' do
      expect(page).to have_text yesterday.strftime('%A %-d %B 12:00')
    end
  end
end
