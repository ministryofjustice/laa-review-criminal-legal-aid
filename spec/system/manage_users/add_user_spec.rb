require 'rails_helper'

RSpec.describe 'Add users from manage users dashboard' do
  include_context 'when logged in user is admin'

  before do
    visit '/'
    visit '/admin/manage_users'
    click_on 'Add new user'
  end

  it 'loads the correct page' do
    heading = first('h1').text

    expect(heading).to have_content 'Add a new user'
  end

  it 'allows a users to cancel the adding of a new user' do
    click_link 'Cancel'
    heading = first('h1').text
    expect(heading).to have_text('Manage users')
  end

  it 'allows a user with management access to be added' do
    fill_in 'Email', with: 'john@example.com'
    check 'Give access to manage other users'

    click_button 'Add user'

    row = find(:xpath, "//table[@class='govuk-table']//tr[contains(td[1], 'john@example.com')]")

    expect(page).to have_text('Email address has been added')
    expect(row).to have_text('john@example.com Yes')
  end

  it 'allows a user without management access to be added' do
    fill_in 'Email', with: 'jane@example.com'

    click_button 'Add user'

    row = find(:xpath, "//table[@class='govuk-table']//tr[contains(td[1], 'jane@example.com')]")

    expect(page).to have_text('Email address has been added')
    expect(row).to have_text('jane@example.com No')
  end

  describe 'validations' do
    it 'errors when no email is provided' do
      check 'Give access to manage other users'
      click_button 'Add user'

      error_message = first('#admin-new-user-form-email-error').text.squish

      expect(error_message).to have_text('Please enter an email')
    end

    it 'errors when email is in the wrong format' do
      fill_in 'Email', with: 'WRONG FORMAT'
      check 'Give access to manage other users'
      click_button 'Add user'

      error_message = first('#admin-new-user-form-email-error').text.squish

      expect(error_message).to have_text('Invalid email format')
    end

    it 'errors if the user is not unique / already exists' do
      add_two_of_the_same_user
      error_message = first('#admin-new-user-form-email-error').text.squish
      expect(error_message).to have_text('User already exists')
    end

    def add_two_of_the_same_user
      fill_in 'Email', with: 'jane@example.com'
      click_button 'Add user'
      click_on 'Add new user'
      fill_in 'Email', with: 'jane@example.com'
      click_button 'Add user'
    end
  end
end
