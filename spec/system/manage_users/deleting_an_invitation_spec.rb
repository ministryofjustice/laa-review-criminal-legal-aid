require 'rails_helper'

RSpec.describe 'Deleting an invitation' do
  include_context 'when logged in user is admin'

  before do
    user
    visit manage_users_invitations_path
  end

  let(:user) { User.create(email: 'Zoe.Example@example.com') }
  let(:actions) { page.first('ul.govuk-summary-list__actions-list') }

  describe 'deleting an invitation' do
    context 'when the invitation is extant' do
      before do
        click_on('Zoe.Example@example.com')

        within actions do
          click_on('Delete')
        end
      end

      it 'shows the confirm page with warning' do
        expect(page).to have_text "Are you sure you want to delete #{user.email}'s invitation?"
        expect(page).to have_text "!WarningThis will mean #{user.email} can no longer activate their account."
      end

      it 'removes the invitation on confirm' do
        expect { click_button 'Yes, delete the invitation' }.to change { User.count }.by(-1)

        expect(page).to have_success_notification_banner(
          text: 'Invitation to Zoe.Example@example.com has been deleted'
        )
      end

      it 'does not delete when abandoned' do
        expect { click_link 'No, do not delete the invitation' }.not_to(change { User.count })

        expect(page).to have_current_path(manage_users_invitations_path)
      end
    end

    context 'when the invitation has expired' do
      before do
        user.update(invitation_expires_at: 1.hour.ago)
        click_on('Zoe.Example@example.com')

        within actions do
          click_on('Delete')
        end
      end

      it 'shows the confirm page without the warning' do
        expect(page).to have_text "Are you sure you want to delete #{user.email}'s invitation?"
        expect(page).to have_no_text '!Warning'
      end
    end
  end
end
