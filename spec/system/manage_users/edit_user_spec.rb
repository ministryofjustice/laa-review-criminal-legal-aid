require 'rails_helper'

RSpec.describe 'Edit users from manage users dashboard' do
  include_context 'when logged in user is admin'
  include_context 'with an existing user'
  include_context 'with many other users'

  let(:confirm_path) { edit_admin_manage_users_active_user_path(user) }

  describe 'with at least 2 other active admins' do
    before do
      User.create!(can_manage_others: true, auth_subject_id: SecureRandom.uuid)
      user
      visit admin_manage_users_root_path

      within(user_row) do
        click_link 'Edit'
      end
    end

    it 'has 2 other active admins' do
      expect(User.admins.size).to eq 2
      expect(user.can_manage_others).to be false
    end

    it 'loads the correct page' do
      heading = first('h1').text

      expect(heading).to have_content 'Edit a user'
      expect(page).to have_field('Give access to manage other users', checked: false)
    end

    it 'allows a users to cancel the editing of a user' do
      expect { click_on('Cancel') }.to(
        change { page.current_path }.from(confirm_path).to(admin_manage_users_root_path)
      )
    end

    context 'when update fails' do
      before do
        allow_any_instance_of(User).to receive(:update).and_return(false)
        click_button 'Save'
      end

      it 'rerenders the edit page' do
        expect(page).to have_current_path edit_admin_manage_users_active_user_path(user)
      end
    end

    context 'when granting management access' do
      before do
        check 'Give access to manage other users'
        click_button 'Save'
      end

      it 'redirects to the correct page' do
        expect(page).to have_current_path('/admin/manage_users')
      end

      it 'shows correct success flash message' do
        expect(page).to have_content('Zoe Blogs has been updated')
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
        expect(page).to have_current_path('/admin/manage_users')
      end

      it 'shows correct success flash message' do
        expect(page).to have_content('Zoe Blogs has been updated')
      end

      it 'updates can manage others value to No' do
        visit '/admin/manage_users'
        expect(user_row).to have_text("#{user.email} No")
      end
    end
  end

  describe 'with only 2 active admins' do
    before do
      other_admin
      user
      visit admin_manage_users_root_path

      within(other_admin_row) do
        click_link 'Edit'
      end
    end

    let(:other_admin) do
      User.create!(
        can_manage_others: true,
        email: 'Jim.Admin1@example.com',
        auth_subject_id: SecureRandom.uuid
      )
    end

    let(:other_admin_row) do
      find(
        :xpath,
        "//table[@class='govuk-table']//tr[contains(td[2], '#{other_admin.email}')]"
      )
    end

    it 'shows edit user page' do
      expect(page).to have_current_path edit_admin_manage_users_active_user_path(other_admin)
      expect(page.find('input#can-manage-others-true-field')).to be_checked
    end

    it 'has 2 active admins' do
      expect(User.admins.size).to eq 2
    end

    context 'when "can_manage_others" permission is unticked' do
      before do
        uncheck 'Give access to manage other users'
        click_button 'Save'
      end

      it 'fails to save', aggregate_failures: true do
        expect(page).to have_current_path edit_admin_manage_users_active_user_path(other_admin)

        within('div.govuk-notification-banner__heading') do
          expect(page).to have_content(
            'Unable to deactivate user. There must be at least two users who can manage others'
          )
        end
      end
    end
  end
end
