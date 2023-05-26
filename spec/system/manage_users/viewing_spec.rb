require 'rails_helper'

RSpec.describe 'Manage Users Dashboard' do
  include_context 'with many other users'

  context 'when user does not have access manage other users' do
    before do
      visit admin_manage_users_root_path
    end

    it 'redirects to Your list page' do
      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq('Page not found')
    end
  end

  context 'when user does have access to manage other users' do
    include_context 'when logged in user is admin'

    let(:last_auth_at) { Time.zone.now }

    before do
      visit admin_manage_users_root_path
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

      expect(column_headings).to eq('Name Email Manage other users Last authentication Actions')
    end

    it 'shows the correct table content' do
      first_data_row = page.first('.govuk-table tbody tr').text
      expect(first_data_row).to eq([current_user.name, current_user.email, 'Yes',
                                    I18n.l(last_auth_at, format: :timestamp)].join(' '))
    end

    describe 'ordering of users in the list' do
      before do
        users = [
          {
            first_name: 'Hassan',
            last_name: 'Example',
            email: 'hassan.example@example.com',
            auth_subject_id: SecureRandom.uuid
          },
          {
            first_name: 'Hassan',
            last_name: 'Sample',
            email: 'hassan.sample@example.com',
            auth_subject_id: SecureRandom.uuid
          },
          {
            first_name: 'Arthur',
            last_name: 'Sample',
            email: 'arthur.sample@example.com',
            auth_subject_id: SecureRandom.uuid
          }
        ]

        User.insert_all(users) # rubocop:disable Rails/SkipsModelValidations

        visit admin_manage_users_root_path
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
        expect(page.all('tbody tr td:nth-child(2)').map(&:text)).to eq expected_order
      end
    end
  end

  context 'with pagination' do
    let(:last_auth_at) { Time.zone.now }

    before do
      make_users(100)
      visit '/'
      User.update(current_user_id, can_manage_others: true, last_auth_at: last_auth_at)
      visit '/admin/manage_users?page=2'
    end

    it 'shows the correct page number' do
      current_page = first('.govuk-pagination__item--current').text

      expect(current_page).to have_text('2')
    end

    it 'shows 50 entries per page' do
      expect(page).to have_selector('.govuk-table__body > .govuk-table__row', count: 50)
    end
  end
end
