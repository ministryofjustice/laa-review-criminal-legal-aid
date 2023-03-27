require 'rails_helper'

RSpec.describe 'Sign out' do
  before do
    visit '/'
    click_link 'Sign out'
  end

  it 'signs the user out' do
    expect(page).not_to have_content 'Your list'
  end

  it 'shows the notification banner' do
    expect(page).to have_success_notification_banner(
      text: 'You have been signed out'
    )
  end
end
