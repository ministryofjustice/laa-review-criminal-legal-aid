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

    it 'can navigate to the end of the the previous day' do
      expect { click_link(previous_day) }.to change { current_path }
        .from('/reporting/workload_report/now')
        .to("/reporting/workload_report/#{yesterday}/at/23:59")
    end

    it 'does not show a link to the next day' do
      expect(page).to have_no_link(next_day)
    end

    context 'when the report_type is not supported' do
      let(:report_type) { Types::TemporalReportType['caseworker_report'] }

      it 'shows the page not found' do
        expect(page).to have_http_status(:forbidden)
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
