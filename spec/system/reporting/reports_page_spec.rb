require 'rails_helper'

RSpec.describe 'Reports' do
  before do
    travel_to Time.zone.local(2023, 11, 28, 12)
  end

  describe 'when logged in as a user manager' do
    include_context 'when logged in user is admin'

    it 'denies access to the "Reports" page' do
      visit reporting_root_path

      expect_forbidden
    end

    it 'is shown forbidden for report pages', :aggregate_failures do
      %w[processed_report caseworker_report workload_report].each do |report|
        visit reporting_user_report_path(report)
        expect(page).to have_http_status(:forbidden)
      end
    end

    context 'when logged in on staging' do
      before do
        allow(FeatureFlags).to receive(:allow_user_managers_service_access) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: true)
        }
        visit reporting_root_path
      end

      it 'can access the "Reports" index page' do
        heading_text = page.first('.govuk-heading-xl').text
        expect(heading_text).to eq('Reports')
      end

      it 'shows the latest complete caseworker daily report' do
        expect { click_link('Caseworker report') }.to change { current_path }
          .from('/reporting')
          .to('/reporting/caseworker_report/daily/2023-11-27')

        expect(page).to have_http_status :ok
      end

      it 'is shown the processed report' do
        expect { click_link('Processed report') }.to change { current_path }
          .from('/reporting')
          .to('/reporting/processed_report')

        expect(page).to have_http_status :ok
      end

      it 'is shown the workload report' do
        click_on 'Workload report'
        expect(page).to have_text('Workload report')

        expect(page).to have_http_status :ok
      end
    end
  end

  context 'when logged in as a caseworker' do
    it 'cannot access reports dashboard' do
      visit reporting_root_path
      expect_forbidden
    end

    it 'cannot access the caseworker report' do
      visit reporting_user_report_path('caseworker_report')
      expect(page).to have_http_status(:forbidden)
    end

    it 'can access the processed report' do
      visit reporting_user_report_path('processed_report')
      expect(page).to have_text('Processed report')
      expect(page).to have_http_status :ok
    end

    it 'can access the workload mini report' do
      visit reporting_user_report_path('current_workload_report')
      expect(page).to have_text('Workload report')
      expect(page).to have_http_status :ok
    end
  end

  context 'when logged in as a supervisor' do
    let(:current_user_role) { UserRole::SUPERVISOR }

    before do
      visit reporting_root_path
    end

    it 'can access the "Reports" index page' do
      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq('Reports')
    end

    it 'shows the latest complete caseworker daily report' do
      expect { click_link('Caseworker report') }.to change { current_path }
        .from('/reporting')
        .to('/reporting/caseworker_report/daily/2023-11-27')

      expect(page).to have_http_status :ok
    end

    it 'is shown the processed report' do
      expect { click_link('Processed report') }.to change { current_path }
        .from('/reporting')
        .to('/reporting/processed_report')

      expect(page).to have_http_status :ok
    end

    it 'is shown the workload report' do
      click_on 'Workload report'
      expect(page).to have_text('Workload report')

      expect(page).to have_http_status :ok
    end
  end

  context 'when logged in as a data_analyst' do
    let(:current_user_role) { UserRole::DATA_ANALYST }

    before do
      visit reporting_root_path
    end

    it 'can access the "Reports" index page' do
      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq('Reports')
    end

    it 'shows the latest complete caseworker monthly report' do
      expect { click_link('Caseworker report') }.to change { current_path }
        .from('/reporting')
        .to('/reporting/caseworker_report/monthly/2023-October')

      expect(page).to have_http_status :ok
    end

    it 'is shown the processed report' do
      expect { click_link('Processed report') }.to change { current_path }
        .from('/reporting')
        .to('/reporting/processed_report')

      expect(page).to have_http_status :ok
    end

    it 'is shown the workload report' do
      click_on 'Workload report'
      expect(page).to have_text('Workload report')

      expect(page).to have_http_status :ok
    end
  end

  context 'when a user can access a report but the report is not supported on the dashboard' do
    let(:current_user_role) { UserRole::SUPERVISOR }

    before do
      stub_const('Types::USER_ROLE_REPORTS', { Types::SUPERVISOR_ROLE => ['not_supported_report'] })
      visit reporting_user_report_path('not_supported_report')
    end

    it 'shows page not found' do
      expect(current_user.reports.include?('not_supported_report')).to be true # confirm stub
      expect(page).to have_http_status :forbidden
    end
  end
end
