require 'rails_helper'

RSpec.describe 'Add users from manage users dashboard' do
  include_context 'with a logged in user'

  before do
    visit '/'
    visit '/admin/manage_users'
    click_on 'Add new user'
  end

  it 'loads the correct page' do
    heading = page.first('h1').text

    expect(heading).to have_content 'Add a new user'
  end

  it 'allows a user with management access to be added' do
    fill_in 'Email', with: 'john@example.com'
    check 'Give access to manage other users'

    click_button 'Add user'

    expect(page).to have_text('A new user has been created')
    expect(page).to have_text('Yes')
  end

  it 'allows a user without management access to be added' do
    fill_in 'Email', with: 'jane@example.com'

    click_button 'Add user'

    expect(page).to have_text('A new user has been created')
    expect(page).to have_text('No')
  end
end
