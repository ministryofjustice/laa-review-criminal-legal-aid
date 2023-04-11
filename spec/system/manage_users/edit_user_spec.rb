require 'rails_helper'

RSpec.describe 'Edit users from manage users dashboard' do
  include_context 'with a logged in admin user'
  include_context 'with an existing user'
  include_context 'with many other users'

  before do
    make_users(50)

    user
    visit '/'
    visit '/admin/manage_users?page=3'
    within(user_row) do
      click_link 'Edit'
    end
  end

  it 'loads the correct page' do
    heading = first('h1').text

    expect(heading).to have_content 'Edit a user'
    expect(page).to have_field('Give access to manage other users', checked: false)
  end

  it 'allows a users to cancel the editing of a user' do
    click_link 'Cancel'
    heading = first('h1').text
    current_page = first('.govuk-pagination__item--current').text

    expect(heading).to have_text('Manage users')
    expect(current_page).to have_text('3')
  end

  context 'when update fails' do
    before do
      allow_any_instance_of(User).to receive(:update).and_return(false)
      click_button 'Save'
    end

    it 'rerenders the edit page' do
      heading = first('h1').text

      expect(heading).to have_content 'Edit a user'
    end
  end

  context 'when granting management access' do
    before do
      check 'Give access to manage other users'
      click_button 'Save'
    end

    it 'redirects to the correct page' do
      expect(page).to have_current_path('/admin/manage_users?page=3')
    end

    it 'shows correct success flash message' do
      expect(page).to have_content('Email address has been updated')
    end

    it 'updates can manage others value to Yes' do
      expect(user_row).to have_text("#{user.email} Yes")
    end
  end

  context 'when revoking management access' do
    before do
      check 'Give access to manage other users'
      click_button 'Save'

      within(user_row) do
        click_link 'Edit'
      end

      uncheck 'Give access to manage other users'
      click_button 'Save'
    end

    it 'redirects to the correct page' do
      expect(page).to have_current_path('/admin/manage_users?page=3')
    end

    it 'shows correct success flash message' do
      expect(page).to have_content('Email address has been updated')
    end

    it 'updates can manage others value to No' do
      visit '/admin/manage_users?page=3'
      expect(user_row).to have_text("#{user.email} No")
    end
  end
end
