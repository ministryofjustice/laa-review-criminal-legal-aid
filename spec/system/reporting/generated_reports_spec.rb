require 'rails_helper'

RSpec.describe 'Generated reports' do
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
    visit reporting_root_path
  end

  context 'when the user is a data analyst' do
    let(:current_user_role) { UserRole::DATA_ANALYST }

    it 'shows the right headings' do
      expect(page).to have_selector('h2', text: 'Downloads')
      expect(page).to have_selector('h3', text: 'Caseworker reports')
    end

    it 'shows the download link' do
      expect(page).to have_link('Download monthly report for April 2025 (CSV)')
    end

    describe 'downloading the report' do
      before do
        click_link('Download monthly report for April 2025 (CSV)')
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

    it 'does not show the headings' do
      expect(page).not_to have_text('Downloads')
      expect(page).not_to have_text('Caseworker reports')
    end

    it 'does not show the download link' do
      expect(page).not_to have_link('Download monthly report for April 2025 (CSV)')
    end

    it 'cannot visit the download link to get the report' do
      visit reporting_download_generated_report_path(generated_report)
      expect(page).to have_http_status :forbidden
    end
  end
end
