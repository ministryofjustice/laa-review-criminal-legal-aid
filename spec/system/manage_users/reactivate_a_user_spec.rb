require 'rails_helper'

RSpec.describe 'Reactivate a user from the manage users dashboard' do
  include_context 'when logged in user is admin'
  include_context 'with an existing user'
  let(:confirm_path) { confirm_reactivate_admin_manage_users_deactivated_user_path(deactivated_user) }
  let(:deactivated_user) { active_user }

  before do
    User.create!(can_manage_others: true, auth_subject_id: SecureRandom.uuid)
    active_user.deactivate!
    visit admin_manage_users_deactivated_users_path
  end

  describe 'reactivating a deactivated user' do
    before do
      within user_row do
        click_on('Reactivate')
      end
    end

    it 'prompts to confirm the action' do
      expect(page).to have_content(
        "Are you sure you want to reactivate Zoe Blogs's account?"
      )
    end

    describe 'clicking on "Yes, reactivate"' do
      it 'redirects to the manage users list' do
        expect { click_on('Yes, reactivate') }.to(
          change { page.current_path }.from(confirm_path).to(admin_manage_users_root_path)
        )
      end

      it 'shows the success notice' do
        click_on('Yes, reactivate')

        within('.govuk-notification-banner--success') do
          expect(page).to have_content('Zoe Blogs has been reactivated')
        end
      end

      it 'reactivates the user' do
        expect { click_on('Yes, reactivate') }.to(
          change { active_user.reload.deactivated? }.from(true).to(false)
        )
      end
    end

    describe 'clicking on "No, do not reactivate"' do
      it 'redirects to the manage user list' do
        expect { click_on('No, do not reactivate') }.to(
          change { page.current_path }.from(confirm_path).to(admin_manage_users_deactivated_users_path)
        )
      end

      it 'does not reactivate the user' do
        expect { click_on('No, do not reactivate') }.not_to(
          change { active_user.reload.deactivated? }.from(true)
        )
      end
    end
  end
end
