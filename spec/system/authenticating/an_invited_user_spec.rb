require 'rails_helper'

RSpec.describe 'Authenticating an invited user' do
  include_context 'when not logged in'

  let(:invited_user) { User.create(email: 'Invited.Test@example.com') }

  context 'when an invited users signs in for the first time' do
    before do
      invited_user
      click_button 'Start now'
      select invited_user.email
    end

    it 'the users is signed in' do
      click_button 'Sign in'
      expect(page).to have_content 'Your list'
    end

    it 'the user is activated' do
      expect { click_button 'Sign in' }.to(
        change { invited_user.reload.activated? }
      )
    end

    describe 'viewing the activation in the user\'s account history' do
      before do
        invited_user.update(can_manage_others: true)
        click_on 'Sign in'
        click_on 'Invited Test'
      end

      let(:cells) { page.first('table tbody tr').all('td') }

      it 'describes the event' do
        expect(cells[1]).to have_content 'Account activated'
      end

      it 'has no associated manager' do
        expect(cells.last).to have_content '-'
      end
    end

    context 'when the invitation has expired' do
      before do
        invited_user.update(invitation_expires_at: Rails.configuration.x.auth.invitation_ttl.ago)
        click_button 'Sign in'
      end

      it 'informs the user that their invitation has expired' do
        expect(page).to have_notification_banner(
          text: 'You cannot access this service',
          details: [
            'Your invitation to access this service has expired.',
            "Contact #{Rails.application.config.x.admin.onboarding_email} for a new invitation."
          ]
        )
      end

      it 'the user is not activated' do
        expect { click_button 'Start now' }.not_to(
          change { invited_user.reload.activated? }
        )
      end
    end
  end
end
