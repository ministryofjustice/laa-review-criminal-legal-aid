require 'rails_helper'

RSpec.describe 'Authenticating a dormant user' do
  before do
    click_link 'Sign out'
    current_user.update(last_auth_at: Rails.configuration.x.auth.dormant_account_threshold.ago)
    click_button 'Sign in'
    select current_user.email
    click_button 'Sign in'
  end

  it 'the user is not signed in' do
    expect(page).not_to have_content 'Your list'
  end

  it 'the user cannot see the nav' do
    expect(page).not_to have_content 'Closed applications'
  end

  it 'shows the correct title' do
    expect(page).to have_css('h1.govuk-heading-xl', text: 'You cannot access this service')
  end

  it 'shows the correct body' do
    expect(page).to have_css('p.govuk-body',
                             text: 'This is because you have not signed in to the service for more than 6 months.')
    expect(page).to have_css('p.govuk-body',
                             text: 'Contact LAAapplyonboarding@justice.gov.uk to reactivate your account.')
  end

  it 'does not show the sign in button' do
    expect(page).not_to have_button('Sign in')
  end
end
