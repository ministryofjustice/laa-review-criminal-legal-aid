require 'rails_helper'

RSpec.describe 'Authenticating a deactivated user' do
  before do
    click_on 'Sign out'
    current_user.update(deactivated_at: Time.current)
    click_button 'Start now'
    select current_user.email
    click_button 'Sign in'
  end

  it 'the user is not signed in' do
    expect(page).not_to have_content 'Your list'
  end

  it 'the user is informed that access to the service is restricted' do
    expect(page).to have_content 'Access to this service is restricted'
    expect(page).to have_http_status(:forbidden)
  end
end
