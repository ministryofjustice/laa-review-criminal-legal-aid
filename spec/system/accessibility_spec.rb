require 'rails_helper'

RSpec.describe 'Accessibility' do
  include_context 'with a logged in admin user'
  include_context 'with an existing user'
  include_context 'with an existing application'

  let(:accessibility_standards) { [:wcag2a, :wcag2aa] }

  before do
    driven_by(:headless_chrome)
    visit '/'
  end

  # it 'viewing assigned applications page has no axe detectible accessibility issues' do
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end

  # it 'open applications page has no axe detectible accessibility issues' do
  #   visit open_crime_applications_path
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end

  # it 'closed applications page has no axe detectible accessibility issues' do
  #   visit closed_crime_applications_path
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end

  # it 'auth failure page has no axe detectible accessibility issues' do
  #   visit auth_failure_path
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end

  # it 'application not found page has no axe detectible accessibility issues' do
  #   visit application_not_found_path
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end

  # it 'unhandled page has no axe detectible accessibility issues' do
  #   visit unhandled_path
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end

  # it 'forbidden page has no axe detectible accessibility issues' do
  #   visit forbidden_path
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end

  # it 'application search page has no axe detectible accessibility issues' do
  #   visit search_application_searches_path
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end

  # it 'application search results page has no axe detectible accessibility issues' do
  #   visit new_application_searches_path
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end

  # it 'assigned applications page has no axe detectible accessibility issues' do
  #   visit assigned_applications_path
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end

  # it 'manage user page has no axe detectible accessibility issues' do
  #   visit admin_manage_users_path
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end

  # it 'add new user page has no axe detectible accessibility issues' do
  #   visit new_admin_manage_user_path
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end

  # it 'deactivate user page has no axe detectible accessibility issues' do
  #   visit new_admin_manage_user_deactivate_users_path(active_user)
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end

  # it 'edit user page has no axe detectible accessibility issues' do
  #   visit edit_admin_manage_user_path(active_user)
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end

  # it 'reassign crime application page has no axe detectible accessibility issues' do
  #   visit new_crime_application_reassign_path(crime_application_id)
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end

  it 'return crime application page has no axe detectible accessibility issues' do
    visit new_crime_application_return_path(crime_application_id)
    expect(page).to be_axe_clean.according_to accessibility_standards
  end

  it 'view crime application page has no axe detectible accessibility issues' do
    visit crime_application_path(crime_application_id)
    expect(page).to be_axe_clean.according_to accessibility_standards
  end

  it 'crime application history page has no axe detectible accessibility issues' do
    visit history_crime_application_path(crime_application_id)
    expect(page).to be_axe_clean.according_to accessibility_standards
  end

  # it 'workload report page has no axe detectible accessibility issues' do
  #   visit report_path(:workload_report)
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end

  # it 'processed report page has no axe detectible accessibility issues' do
  #   visit report_path(:processed_report)
  #   expect(page).to be_axe_clean.according_to accessibility_standards
  # end
end
