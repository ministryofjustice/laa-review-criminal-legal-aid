require 'rails_helper'

RSpec.describe 'Reports' do
  context 'when logged in as a user manager' do
    include_context 'when logged in user is admin'

    it 'redirects to "Manage Users" dashboard' do
      visit reports_path
      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq('Manage users')
    end

    context 'when logged in on staging' do
      before do
        allow(FeatureFlags).to receive(:allow_user_managers_service_access) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: true)
        }
        visit reports_path
      end

      it 'can access the "Reports" index page as a user manager' do
        heading_text = page.first('.govuk-heading-xl').text
        expect(heading_text).to eq('Reports')
      end

      it 'is shown the caseworker report' do
        expect(page).to have_text('Caseworker report')
      end

      it 'is shown the processed report' do
        expect(page).to have_text('Processed report')
      end

      it 'is shown the workload report' do
        expect(page).to have_text('Workload report')
      end
    end
  end

  context 'when logged in as a caseworker' do
    before do
      visit reports_path
    end

    it 'cannot access reports dashboard' do
      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq('Page not found')
    end

    it 'can access the processed report' do
      visit report_path('processed_report')
      expect(page).to have_text('Processed report')
    end

    it 'can access the workload report' do
      visit report_path('workload_report')
      expect(page).to have_text('Workload report')
    end

    it 'cannot access the caseworker report' do
      visit report_path('caseworker_report')
      expect(page).to have_text('Page not found')
    end
  end

  context 'when logged in as a supervisor' do
    let(:current_user_role) { UserRole::SUPERVISOR }

    before do
      visit reports_path
    end

    it 'can access the reports page' do
      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq('Reports')
    end

    it 'is shown the caseworker report' do
      click_on 'Caseworker report'
      expect(page).to have_text('Caseworker report')
    end

    it 'is shown the processed report' do
      click_on 'Processed report'
      expect(page).to have_text('Processed report')
    end

    it 'is shown the workload report' do
      click_on 'Workload report'
      expect(page).to have_text('Workload report')
    end
  end
end
