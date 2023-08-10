require 'rails_helper'

RSpec.describe 'Performance Tracking' do
  describe 'User does not have access to performance tracking' do
    include_context 'when logged in user is admin'

    context 'when logged in as a user manager' do
      before do
        visit performance_tracking_index_path
      end

      it 'redirects to "Manage Users" dashboard' do
        heading_text = page.first('.govuk-heading-xl').text
        expect(heading_text).to eq('Manage users')
      end
    end

    context 'when logged in as a caseworker' do
      let(:current_user_can_manage_others) { false }

      before do
        visit performance_tracking_index_path
      end

      it 'redirects to "Page not" found' do
        heading_text = page.first('.govuk-heading-xl').text
        expect(heading_text).to eq('Page not found')
      end
    end
  end

  describe 'User does have access to performance tracking' do
    context 'when logged in as a supervisor' do
      let(:current_user_role) { UserRole::SUPERVISOR }

      before do
        visit performance_tracking_index_path
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

    context 'when logged in on staging' do
      before do
        allow(FeatureFlags).to receive(:allow_user_managers_service_access) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: true)
        }
        visit performance_tracking_index_path
      end

      it 'redirects to "Page not" found for caseworkers' do
        heading_text = page.first('.govuk-heading-xl').text
        expect(heading_text).to eq('Page not found')
      end

      context 'when logged in as a user manager' do
        let(:current_user_can_manage_others) { true }

        it 'can access "Performance tracking" page as a user manager' do
          heading_text = page.first('.govuk-heading-xl').text
          expect(heading_text).to eq('Performance tracking')
        end
      end
    end
  end
end
