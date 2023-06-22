require 'rails_helper'

RSpec.describe 'Authenticating a dormant user' do
  before do
    click_on 'Sign out'
    current_user.update(last_auth_at: Rails.configuration.x.auth.dormant_account_threshold.ago)
    click_button 'Sign in'
    select current_user.email
    click_button 'Sign in'
  end

  it 'the user is not signed in' do
    expect(page).not_to have_content 'Your list'
  end

  it 'informs the user that their invitation has expired' do
    expect(page).to have_notification_banner(
      text: 'You cannot access this service',
      details: [
        'This is because you have not signed in to the service for more than 90 days.',
        "Contact #{Rails.application.config.x.admin.onboarding_email} to reactivate your account."
      ]
    )
  end
end
