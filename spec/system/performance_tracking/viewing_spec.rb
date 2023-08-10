require 'rails_helper'

RSpec.describe 'Performance Tracking' do
  describe 'User does not have access to performance tracking' do
    context 'when logged in as a user manager' do
      include_context 'when logged in user is admin'

      before do
        visit performance_tracking_index_path
      end

      it 'redirects to "Manage Users" dashboard' do
        heading_text = page.first('.govuk-heading-xl').text
        expect(heading_text).to eq('Manage users')
      end

      it 'does not show the performance tracking nav link' do
        expect(page).not_to have_link('Performance tracking')
      end

      context 'when user manager role is supervisor but without service access enabled' do
        let(:current_user_role) { UserRole::SUPERVISOR }

        it 'redirects to "Manage Users" dashboard' do
          heading_text = page.first('.govuk-heading-xl').text
          expect(heading_text).to eq('Manage users')
        end

        it 'does not show the performance tracking nav link' do
          expect(page).not_to have_link('Performance tracking')
        end
      end

      context 'when user manager role is caseworker and service access is enabled' do
        before do
          allow(FeatureFlags).to receive(:allow_user_managers_service_access) {
            instance_double(FeatureFlags::EnabledFeature, enabled?: true)
          }
          visit performance_tracking_index_path
        end

        it 'redirects to "Page not found"' do
          heading_text = page.first('.govuk-heading-xl').text
          expect(heading_text).to eq('Page not found')
        end

        it 'does not show the performance tracking nav link' do
          expect(page).not_to have_link('Performance tracking')
        end
      end
    end

    context 'when logged in as a caseworker' do
      before do
        visit performance_tracking_index_path
      end

      it 'redirects to "Page not found"' do
        heading_text = page.first('.govuk-heading-xl').text
        expect(heading_text).to eq('Page not found')
      end
    end
  end

  describe 'User does have access to performance tracking' do
    context 'when logged in as a supervisor' do
      let(:current_user_role) { UserRole::SUPERVISOR }

      before do
        click_link 'Performance tracking'
      end

      it 'can access "Performance tracking" page' do
        heading_text = page.first('.govuk-heading-xl').text
        expect(heading_text).to eq('Performance tracking')
      end

      it 'can view the caseworker report' do
        within('div.govuk-warning-text') do
          expect(page).to have_text(
            'This report is experimental and under active development. It may contain inaccurate information.'
          )
        end
      end
    end

    context 'when logged in as a user manager and supervisor, and service access is enabled' do
      include_context 'when logged in user is admin'

      let(:current_user_role) { UserRole::SUPERVISOR }

      before do
        allow(FeatureFlags).to receive(:allow_user_managers_service_access) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: true)
        }
        visit '/'
        click_link 'Performance tracking'
      end

      it 'can access "Performance tracking" page as a user manager' do
        heading_text = page.first('.govuk-heading-xl').text
        expect(heading_text).to eq('Performance tracking')
      end
    end
  end
end
