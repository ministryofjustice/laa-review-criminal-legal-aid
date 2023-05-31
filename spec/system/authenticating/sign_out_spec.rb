require 'rails_helper'

RSpec.describe 'Sign out' do
  before do
    visit '/'
    click_link 'Sign out'
  end

  it 'signs the user out' do
    expect(page).not_to have_content 'Your list'
  end

  it 'shows the sign out confirmation page' do
    expect(page).to have_css('h1.govuk-heading-xl', text: 'You have signed out')
    expect(page).to have_button('Sign in')
  end
end
