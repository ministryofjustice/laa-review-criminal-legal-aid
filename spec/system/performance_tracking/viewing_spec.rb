require 'rails_helper'

RSpec.describe 'Performance Tracking Dashboard' do
  describe 'User does not have access to performance tracking' do
    include_context 'when logged in user is admin'

    context 'when logged in as user manager' do
      before do
        visit performance_tracking_index_path
      end

      it 'redirects to "Manage Users" dashboard' do
        heading_text = page.first('.govuk-heading-xl').text
        expect(heading_text).to eq('Manage users')
      end
    end

    context 'when logged in as caseworker' do
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
    context 'when logged in as supervisor' do
      let(:current_user_role) { UserRole::SUPERVISOR }

      before do
        visit performance_tracking_index_path
      end

      it 'can access "Performance tracking" page' do
        heading_text = page.first('.govuk-heading-xl').text
        expect(heading_text).to eq('Performance tracking')
      end
    end
  end
end
