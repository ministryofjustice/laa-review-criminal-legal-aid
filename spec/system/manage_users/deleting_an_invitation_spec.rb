require 'rails_helper'

RSpec.describe 'Deleting an invitation' do
  include_context 'when logged in user is admin'

  before do
    user
    visit admin_manage_users_invitations_path
  end

  let(:user) { User.create(email: 'Zoe.Example@example.com') }

  let(:user_row) do
    find(:xpath, "//table[@class='govuk-table']//tr[contains(td[1], '#{user.email}')]")
  end

  describe 'deleting an invitation' do
    let(:click_delete) do
      within user_row do
        click_on('Delete')
      end
    end

    context 'when the invitation is extant' do
      it 'removes the invitation' do
        expect { click_delete }.to change { User.count }.by(-1)
      end

      it 'notifies that the invitation was removed' do
        click_delete

        expect(page).to have_success_notification_banner(
          text: 'Invitation to Zoe.Example@example.com has been deleted'
        )
      end
    end

    context 'when the invitation has expired' do
      before do
        user.update(invitation_expires_at: 1.hour.ago)
      end

      it 'removes the invitation' do
        expect { click_delete }.to change { User.count }.by(-1)
      end

      it 'notifies that the invitation was removed' do
        click_delete

        expect(page).to have_success_notification_banner(
          text: 'Invitation to Zoe.Example@example.com has been deleted'
        )
      end
    end
  end
end
