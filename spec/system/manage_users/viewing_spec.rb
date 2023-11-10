require 'rails_helper'

RSpec.describe 'Manage Users Dashboard' do
  context 'when user does not have access manage other users' do
    before do
      visit manage_users_root_path
    end

    it 'redirects to "Page not" found' do
      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq('Page not found')
    end
  end

  context 'when user does have access to manage other users' do
    include_context 'when logged in user is admin'

    let(:last_auth_at) { Time.zone.now }

    before do
      visit manage_users_root_path
    end

    it 'includes the page heading' do
      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq('Manage users')
    end

    it 'includes the button to add new user' do
      add_new_user_button = page.first('.govuk-button').text
      expect(add_new_user_button).to have_content 'Invite a user'
    end

    it 'includes the correct table headings' do
      column_headings = page.first('.govuk-table thead tr').text.squish

      expect(column_headings).to eq('Name Email Manage other users Role')
    end

    it 'shows the correct table content' do
      first_data_row = page.first('.govuk-table tbody tr').text
      expect(first_data_row).to eq([current_user.name, current_user.email, 'Yes', 'Caseworker'].join(' '))
    end

    it_behaves_like 'a paginated page', path: '/manage_users?page=2'
    it_behaves_like 'an ordered user list' do
      let(:path) { manage_users_root_path }
      let(:expected_order) do
        %w[arthur.sample@example.com hassan.example@example.com hassan.sample@example.com Joe.EXAMPLE@justice.gov.uk]
      end
      let(:column_num) { 2 }
    end
  end
end
