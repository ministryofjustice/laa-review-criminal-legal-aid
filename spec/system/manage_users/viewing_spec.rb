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
    let(:last_auth_at) { Time.zone.now }

    before do
      visit '/'
      User.update(current_user_id, can_manage_others: true, last_auth_at: last_auth_at)
      visit '/admin/manage_users'
    end

    it 'includes the page heading' do
      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq('Manage users')
    end

    # it_behaves_like 'Accessible'

    it 'includes the button to add new user' do
      add_new_user_button = page.first('.govuk-button').text
      expect(add_new_user_button).to have_content 'Add new user'
    end

    it 'includes the correct table headings' do
      column_headings = page.first('.govuk-table thead tr').text.squish

      expect(column_headings).to eq('Email Last authentication Manage other users Actions')
    end

    it 'shows the correct table content' do
      first_data_row = page.first('.govuk-table tbody tr').text
      expect(first_data_row).to eq([current_user.email, I18n.l(last_auth_at, format: :timestamp), 'Yes'].join(' '))
    end

    describe 'ordering of users in the list' do
      before do
        User.create(first_name: 'Hassan', last_name: 'Example', email: 'hassan.example@example.com')
        User.create(first_name: 'Hassan', last_name: 'Sample', email: 'hassan.sample@example.com')
        User.create(first_name: 'Arthur', last_name: 'Sample', email: 'arthur.sample@example.com')
        visit '/admin/manage_users'
      end

      let(:expected_order) do
        [
          'arthur.sample@example.com',
          'hassan.example@example.com',
          'hassan.sample@example.com',
          'Joe.EXAMPLE@justice.gov.uk'
        ]
      end

      it 'is ordered by first name, last name' do
        expect(page.all('tbody tr td:first-child').map(&:text)).to eq expected_order
      end
    end
  end
end
