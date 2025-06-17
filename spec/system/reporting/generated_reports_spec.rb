require 'rails_helper'

RSpec.describe 'Generated reports' do
  describe 'caseworker report' do
    let!(:generated_report) do
      GeneratedReport.create!(
        report_type: 'caseworker_report',
        interval: 'monthly',
        period_start_date: Date.parse('2025-04-01'),
        period_end_date: Date.parse('2025-04-30'),
        report: {
          io: StringIO.new('caseworker report'),
          filename: 'caseworker_report_monthly_2025-April.csv',
          content_type: 'text/csv',
        }
      )
    end

    before do
      visit reporting_temporal_report_path(report_type: 'caseworker_report', interval: 'monthly', period: '2025-April')
    end

    context 'when the user is a data analyst' do
      let(:current_user_role) { UserRole::DATA_ANALYST }

      it 'shows the download link' do
        expect(page).to have_link('Download source data (CSV)')
      end

      describe 'downloading the report' do
        before do
          click_link('Download source data (CSV)')
        end

        it 'has the correct content type' do
          expect(page.driver.response.content_type).to eq('text/csv')
        end

        it 'has the correct body' do
          expect(page.driver.response.body).to eq('caseworker report')
        end

        it 'has the correct file name' do
          expect(page.driver.response.headers['Content-Disposition']).to match(
            'caseworker_report_monthly_2025-April.csv'
          )
        end

        it 'can visit the download link to get the report' do
          visit reporting_download_generated_report_path(generated_report)
          expect(page.driver.response.headers['Content-Disposition']).to match(
            'caseworker_report_monthly_2025-April.csv'
          )
        end
      end
    end

    context 'when user is a supervisor' do
      let(:current_user_role) { UserRole::SUPERVISOR }

      it 'does not show the download link' do
        expect(page).not_to have_link('Download source data (CSV)')
      end

      it 'cannot visit the download link to get the report' do
        visit reporting_download_generated_report_path(generated_report)
        expect(page).to have_http_status :forbidden
      end
    end
  end
end
