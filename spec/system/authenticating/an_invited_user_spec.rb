require 'rails_helper'

RSpec.describe 'Authenticating an invited user' do
  include_context 'when not logged in'

  let(:invited_user) { User.create(email: 'Invited.Test@example.com') }

  context 'when an invited users signs in for the first time' do
    before do
      invited_user
      click_button 'Sign in'
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

    context 'when the invitation has expired' do
      before do
        invited_user.update(invitation_expires_at: Rails.configuration.x.auth.invitation_ttl.ago)
        click_button 'Sign in'
      end

      it 'informs the user that their invitation has expired' do
        expect(page).to have_notification_banner(
          text: 'Your invitation has expired',
          details: 'Invitations to access this service automatically expire after 48 hours.'
        )
      end

      it 'the user is not activated' do
        expect { click_button 'Sign in' }.not_to(
          change { invited_user.reload.activated? }
        )
      end
    end
  end
end