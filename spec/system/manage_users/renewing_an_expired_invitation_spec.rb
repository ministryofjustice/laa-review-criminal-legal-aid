require 'rails_helper'

RSpec.describe 'Renewing an invitation' do
  include_context 'when logged in user is admin'

  before do
    user
    visit admin_manage_users_invitations_path
  end

  let(:user) { User.create(email: 'Zoe.Example@example.com') }

  let(:user_row) do
    find(:xpath, "//table[@class='govuk-table']//tr[contains(td[1], '#{user.email}')]")
  end

  describe 'renew an invitation' do
    let(:click_renew) do
      within user_row do
        click_on('Renew')
      end
    end

    context 'when the invitation is extant' do
      it 'does not show the renew button' do
        expect(page).not_to have_button 'Renew'
      end
    end

    context 'when the invitation has expired' do
      before do
        user.update(invitation_expires_at: 1.hour.ago)
        visit admin_manage_users_invitations_path
        click_renew
      end

      it 'shows the confirm mage' do
        expect(page).to have_text "Are you sure you want to extend #{user.email}'s invitation for 48 hours?"
      end

      it 'renews on confirm' do
        expect { click_button 'Yes, renew the invitation' }.to(
          change { user.reload.invitation_expired? }.from(true).to(false)
        )

        expect(page).to have_success_notification_banner(
          text: 'Invitation to Zoe.Example@example.com has been renewed'
        )
      end

      it 'does not renew when abandoned' do
        expect { click_link 'No, do not renew the invitation' }.not_to(change { user.reload.invitation_expired? })

        expect(page).to have_current_path(admin_manage_users_invitations_path)
      end
    end
  end
end