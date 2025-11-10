require 'rails_helper'

RSpec.describe 'Volumes by office report' do
  let(:report_type) { Types::TemporalReportType['submissions_by_office'] }
  let(:report_title) { 'Submissions by office report' }
  let(:download_link) { 'Download report (CSV)' }
  let(:complete_report_path) { 'reporting/volumes_by_office_report/monthly/2025-October' }

  before do
    visit '/reporting'
  end

  context 'when a Data Analyts' do
    let(:current_user_role) { UserRole::DATA_ANALYST }

    it 'shows a link on the user reports page' do
      expect(page).to have_link report_title
    end

    it 'does not show the download link on incomplete reports' do
      click_link(report_title)
      click_link('Next')
      expect(page).not_to have_link(download_link)
      expect(page).to have_text(
        "This report isn't available yet. You’ll be able to download it after the end of the month."
      )
    end

    describe 'attempts to directly view the report' do
      before { visit complete_report_path }

      it 'returns the reports page' do
        expect(page).to have_http_status(:success)
        expect(page).to have_link('Monthly')
      end

      it 'does now show the Weekly or Daily tabs' do
        expect(page).not_to have_link('Daily')
        expect(page).not_to have_link('Weekly')
      end

      describe 'downloading the report' do
        before do
          stub_request(
            :get,
            'https://datastore-api-stub.test/api/v1/reporting/volumes_by_office/monthly/2025-October'
          ).to_return_json(
            body: { 'data' => { '1A2B3C' => 1, '2B3C4D' => 5 } }
          )

          click_link download_link
        end

        it 'has the correct content type' do
          expect(page.driver.response.content_type).to eq('text/csv; charset=utf-8')
        end

        it 'has the correct report details' do
          expect(page.driver.response.body).to eq(
            "office_code,submissions\n1A2B3C,1\n2B3C4D,5\n"
          )
        end

        it 'has the correct file name' do
          expect(page.driver.response.headers['Content-Disposition']).to match(
            'volumes_by_office_report_monthly_2025-October_1_of_1.csv'
          )
        end
      end
    end
  end

  context 'when a supervisor' do
    let(:current_user_role) { UserRole::SUPERVISOR }

    describe 'user reports page' do
      it 'does not show a link on the user reports page' do
        expect(page).not_to have_link report_title
      end
    end

    describe 'attempts to directly view the report' do
      before { visit complete_report_path }

      it 'returns a forbidden error' do
        expect(page).to have_http_status(:forbidden)
      end
    end
  end
end
