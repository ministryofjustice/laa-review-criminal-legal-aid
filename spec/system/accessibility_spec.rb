require 'rails_helper'

RSpec.describe 'Accessibility', :accessibility do
  include_context 'with an existing user'
  include_context 'with an existing application'
  include_context 'with a stubbed mailer'

  let(:accessibility_standards) { [:wcag2a, :wcag2aa] }

  before do
    driven_by(:headless_chrome)
    visit '/'
  end

  describe 'pages that require an authenticated user' do
    it 'viewing assigned applications page has no axe detectable accessibility issues' do
      expect(page).to be_axe_clean.according_to accessibility_standards
    end

    it 'open applications page has no axe detectable accessibility issues' do
      visit open_crime_applications_path
      expect(page).to be_axe_clean.according_to accessibility_standards
    end

    it 'closed applications page has no axe detectable accessibility issues' do
      visit closed_crime_applications_path
      expect(page).to be_axe_clean.according_to accessibility_standards
    end

    it 'forbidden page has no axe detectable accessibility issues' do
      visit 'users/auth/failure'
      expect(page).to be_axe_clean.according_to accessibility_standards
    end

    it 'application search page has no axe detectable accessibility issues' do
      visit search_application_searches_path
      expect(page).to be_axe_clean.according_to accessibility_standards
    end

    it 'application search results page has no axe detectable accessibility issues' do
      visit new_application_searches_path
      expect(page).to be_axe_clean.according_to accessibility_standards
    end

    it 'assigned applications page has no axe detectable accessibility issues' do
      visit assigned_applications_path
      expect(page).to be_axe_clean.according_to accessibility_standards
    end

    it 'manage user page has no axe detectable accessibility issues' do
      visit manage_users_root_path
      expect(page).to be_axe_clean.according_to accessibility_standards
    end

    it 'manage user invitations page has no axe detectable accessibility issues' do
      visit manage_users_invitations_path
      expect(page).to be_axe_clean.according_to accessibility_standards
    end

    it 'add new user page has no axe detectable accessibility issues' do
      visit new_manage_users_invitation_path
      expect(page).to be_axe_clean.according_to accessibility_standards
    end

    it 'deactivate user page has no axe detectable accessibility issues' do
      visit new_manage_users_deactivated_user_path(active_user_id: active_user)
      expect(page).to be_axe_clean.according_to accessibility_standards
    end

    it 'reassign crime application page has no axe detectable accessibility issues' do
      visit new_crime_application_reassign_path(crime_application_id)
      expect(page).to be_axe_clean.according_to accessibility_standards
    end

    it 'return crime application page has no axe detectable accessibility issues' do
      visit new_crime_application_return_path(crime_application_id)
      expect(page).to be_axe_clean.according_to accessibility_standards
    end

    it 'view crime application page has no axe detectable accessibility issues' do
      visit crime_application_path(crime_application_id)
      expect(page).to be_axe_clean.according_to accessibility_standards
    end

    it 'crime application history page has no axe detectable accessibility issues' do
      visit history_crime_application_path(crime_application_id)
      expect(page).to be_axe_clean.according_to accessibility_standards
    end

    it 'workload report page has no axe detectable accessibility issues' do
      visit reporting_user_report_path(:workload_report)
      expect(page).to be_axe_clean.according_to accessibility_standards
    end

    it 'processed report page has no axe detectable accessibility issues' do
      visit reporting_user_report_path(:processed_report)
      expect(page).to be_axe_clean.according_to accessibility_standards
    end
  end

  describe 'pages that can only be reached when not authenticated' do
    it 'the landing page has no axe detectable accessibility issues' do
      visit unauthenticated_root_path
      expect(page).to be_axe_clean.according_to accessibility_standards
    end
  end
end
