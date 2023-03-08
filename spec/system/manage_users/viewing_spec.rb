require 'rails_helper'

RSpec.describe 'Manage Users Dashboard' do
  include_context 'with a logged in user'

  context 'when user does not have access manage other users' do
    before do
      visit '/'
      visit '/admin/manage_users'
    end

    it 'redirects to Your list page' do
      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq('Your list')
    end

    it 'show access denied flash message' do
      expect(page).to have_content('Only authorised users can access the admin page')
    end
  end

  context 'when user does have access to manage other users' do
    before do
      User.update(current_user_id, can_manage_others: true)
      visit '/'
      visit '/admin/manage_users'
    end

    it 'includes the page heading' do
      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq('Manage users')
    end

    it 'includes the button to add new user' do
      add_new_user_button = page.first('.govuk-button').text
      expect(add_new_user_button).to have_content 'Add new user'
    end

    it 'includes the correct table headings' do
      column_headings = page.first('.govuk-table thead tr').text.squish

      expect(column_headings).to eq('Email Manage other users Actions')
    end

    it 'shows the correct table content' do
      first_data_row = page.first('.govuk-table tbody tr').text
      expect(first_data_row).to have_content(current_user.email)
    end
  end
end
