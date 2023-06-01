require 'rails_helper'

RSpec.describe 'Authenticating an invited user' do
  include_context 'when not logged in'

  let(:invited_user) { User.create(email: 'Invited.Test@example.com') }

  context 'when an invited user signs in for the first time' do
    before do
      invited_user
      click_button 'Sign in'
      select invited_user.email
    end

    it 'the user is signed in' do
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

      it 'the user is not activated' do
        visit '/'
        expect { click_button 'Sign in' }.not_to(
          change { invited_user.reload.activated? }
        )
      end

      it 'the user cannot see the nav' do
        expect(page).not_to have_content 'Closed applications'
      end

      it 'the page has the correct title' do
        expect(page).to have_css('h1.govuk-heading-xl', text: 'You cannot access this service')
      end

      it 'the page has the correct body' do
        expect(page).to have_css('p.govuk-body', text: 'Your invitation to access this service has expired.')
        expect(page).to have_css('p.govuk-body',
                                 text: 'Contact LAAapplyonboarding@justice.gov.uk for a new invitation.')
      end

      it 'the page does not show the sign in button' do
        expect(page).not_to have_button('Sign in')
      end
    end
  end
end
