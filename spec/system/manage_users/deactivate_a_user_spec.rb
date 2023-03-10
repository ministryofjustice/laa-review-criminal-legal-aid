require 'rails_helper'

RSpec.describe 'Deactivate a user from the manage users dashboard' do
  include_context 'with a logged in admin user'

  let(:active_user) { user }
  let(:confirm_path) { new_admin_manage_user_deactivate_users_path(active_user) }

  let(:user) do
    User.create!(
      first_name: 'Zoe',
      last_name: 'Blogs',
      email: 'Zoe.Blogs@example.com'
    )
  end

  let(:user_row) do
    find(
      :xpath,
      "//table[@class='govuk-table']//tr[contains(td[1], '#{user.email}')]"
    )
  end

  before do
    active_user
    visit '/'
    visit '/admin/manage_users'
  end

  describe 'clicking on "Deactivate"' do
    before do
      within user_row do
        click_on('Deactivate')
      end
    end

    it 'prompts to confirm the action' do
      expect(page).to have_content(
        'Are you sure you want to deactivate Zoe Blogs?'
      )
    end

    it 'warns about the impact of deactivating' do
      within('div.govuk-warning-text') do
        expect(page).to have_content(
          '! Warning This will mean Zoe Blogs can no longer access this service.'
        )
      end
    end

    describe 'clicking on "Yes, deactivate"' do
      it 'redirects to the manage user list' do
        expect { click_on('Yes, deactivate') }.to(
          change { page.current_path }.from(confirm_path).to(admin_manage_users_path)
        )
      end

      it 'shows the success notice' do
        click_on('Yes, deactivate')

        within('.govuk-notification-banner--success') do
          expect(page).to have_content('Email address has been deactivated')
        end
      end

      it 'deactivates the user' do
        expect { click_on('Yes, deactivate') }.to(
          change { active_user.reload.deactivated? }.from(false).to(true)
        )
      end
    end

    describe 'clicking on "No, do not deactivate"' do
      it 'redirects to the manage user list' do
        expect { click_on('No, do not deactivate') }.to(
          change { page.current_path }.from(confirm_path).to(admin_manage_users_path)
        )
      end

      it 'does not deactivate the user' do
        expect { click_on('No, do not deactivate') }.not_to(
          change { active_user.reload.deactivated? }.from(false)
        )
      end
    end
  end
end
