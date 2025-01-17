require 'rails_helper'

RSpec.describe 'Authenticating a signed out user' do
  before do
    click_on 'Sign out'
    visit '/assigned-applications'
  end

  it 'the cannot access their list' do
    expect(page).to have_no_content 'Your list'
  end

  it 'informs the user that they need to be singed to access the page requested' do
    expect(page).to have_notification_banner(
      text: 'Sign in to access the service'
    )
  end
end
