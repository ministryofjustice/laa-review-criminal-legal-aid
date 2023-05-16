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
      end

      it 'renews the invitation' do
        expect { click_renew }.to change { user.reload.invitation_expired? }.from(true).to(false)
      end

      it 'notifies that the invitation was renewed' do
        click_renew

        expect(page).to have_success_notification_banner(
          text: 'Invitation to Zoe.Example@example.com has been renewed'
        )
      end
    end
  end
end
