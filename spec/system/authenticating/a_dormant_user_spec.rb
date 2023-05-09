require 'rails_helper'

RSpec.describe 'Authenticating a dormant' do
  before do
    click_link 'Sign out'
    current_user.update(last_auth_at: Rails.configuration.x.auth.dormant_account_threshold.ago)
    click_button 'Sign in'
    select current_user.email
    click_button 'Sign in'
  end

  it 'the users is not signed in' do
    expect(page).not_to have_content 'Your list'
  end

  it 'informs the user that their invitation has expired' do
    expect(page).to have_notification_banner(
      text: 'Your access to this service has been restricted',
      details: 'It has been more than 6 months since you last accessed the service. ' \
               'Your account will need to be re-activated before you can sign in.'
    )
  end
end
