require 'rails_helper'

RSpec.describe 'Reactivate a user from the manage users dashboard' do
  include_context 'when logged in user is admin'
  include_context 'with an existing user'
  let(:confirm_path) { confirm_reactivate_manage_users_deactivated_user_path(deactivated_user) }
  let(:deactivated_user) { active_user }

  before do
    User.create!(can_manage_others: true, auth_subject_id: SecureRandom.uuid, email: 'test1@eg.com')
    active_user.deactivate!
    visit manage_users_deactivated_users_path
  end

  describe 'reactivating a deactivated user' do
    before do
      click_on('Zoe Blogs')
      click_on('Reactivate')
    end

    it 'prompts to confirm the action' do
      expect(page).to have_content(
        "Are you sure you want to reactivate Zoe Blogs's account?"
      )
    end

    describe 'clicking on "Yes, reactivate"' do
      it 'redirects to the manage users list' do
        expect { click_on('Yes, reactivate') }.to(
          change { page.current_path }.from(confirm_path).to(manage_users_root_path)
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

      describe 'viewing the deactivation in the user\'s account history' do
        before do
          click_on('Yes, reactivate')
          click_link 'Zoe Blogs'
        end

        let(:cells) { page.first('table tbody tr').all('td') }

        it 'describes the event' do
          expect(cells[1]).to have_content 'Account reactivated'
        end

        it 'includes the manager\'s name' do
          expect(cells.last).to have_content 'Joe EXAMPLE'
        end
      end
    end

    describe 'clicking on "No, do not reactivate"' do
      it 'redirects to the manage user list' do
        expect { click_on('No, do not reactivate') }.to(
          change { page.current_path }.from(confirm_path).to(manage_users_deactivated_users_path)
        )
      end

      it 'does not reactivate the user' do
        expect { click_on('No, do not reactivate') }.not_to(
          change { active_user.reload.deactivated? }.from(true)
        )
      end
    end
  end

  describe 'current_user deactivated' do
    before do
      current_user.update!(deactivated_at: Time.zone.now)
    end

    context 'when viewing deactivated users' do
      before do
        visit manage_users_deactivated_users_path
      end

      let(:current_user_row) do
        find(
          :xpath,
          "//table[@class='govuk-table']//tr[contains(td[2], '#{current_user.email}')]"
        )
      end

      it 'shows current_user in deactivated list' do
        expect(current_user_row).to be_present
      end

      it 'does not have the `Reactivate` link' do
        expect(current_user_row.text.downcase.include?('reactivate')).to be false
      end
    end

    context 'when reactivating themselves' do
      before do
        visit confirm_reactivate_manage_users_deactivated_user_path(current_user)

        click_on('Yes, reactivate')
      end

      it 'denies action', aggregate_failures: true do
        expect(page).to have_current_path(manage_users_deactivated_users_path)
        expect(current_user.deactivated?).to be true
      end

      it 'shows error message' do
        within('div.govuk-notification-banner__heading') do
          expect(page).to have_content('You cannot reactivate yourself')
        end
      end
    end
  end
end
