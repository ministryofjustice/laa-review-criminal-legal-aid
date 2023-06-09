require 'rails_helper'

RSpec.describe 'Authenticating a signed out user' do
  before do
    click_link 'Sign out'
    visit '/assigned_applications'
  end

  it 'the cannot access their list' do
    expect(page).not_to have_content 'Your list'
  end

  it 'informs the user that they need to be singed to access the page requested' do
    expect(page).to have_notification_banner(
      text: 'Sign in to view this page'
    )
  end
end
