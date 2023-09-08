require 'rails_helper'

RSpec.describe 'Renewing an invitation' do
  include_context 'when logged in user is admin'

  before do
    user
    Authorising::Invite.call(user: user, user_manager_id: current_user.id)
    visit manage_users_invitations_path
  end

  let(:user) { User.create(email: 'Zoe.Example@example.com') }
  let(:actions) { page.first('ul.govuk-summary-list__actions-list') }

  describe 'renew an invitation' do
    context 'when the invitation is extant' do
      it 'does not show the renew button' do
        expect(page).not_to have_button 'Renew'
      end
    end

    context 'when the invitation has expired' do
      before do
        user.update(invitation_expires_at: 1.hour.ago)

        visit manage_users_invitations_path
        click_on('Zoe.Example@example.com')

        within actions do
          click_on('Renew')
        end
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

        expect(page).to have_current_path(manage_users_invitations_path)
      end

      describe 'logging the invitation renewal in the user\'s account history' do
        before do
          click_on('Yes, renew the invitation')
          click_link user.email
        end

        let(:cells) { page.first('table tbody tr').all('td') }

        it 'describes the event' do
          expect(cells[1]).to have_content 'Invitation renewed'
        end

        it 'includes the manager\'s name' do
          expect(cells.last).to have_content 'Joe EXAMPLE'
        end
      end
    end
  end
end
