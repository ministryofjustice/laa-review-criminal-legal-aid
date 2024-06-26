require 'rails_helper'

RSpec.describe 'Authenticating with the DevAuth strategy' do
  include_context 'when not logged in'
  before { user }

  let(:user) { nil }

  describe 'clicking the "Sign in" button' do
    before do
      click_button 'Start now'
    end

    it 'shows the dev auth page' do
      expect(page).to have_current_path '/dev_auth'
      expect(page).to have_content 'This is a mock sign in page for use in local development only'
    end

    context 'when the "Not Authorised" user is chosen' do
      before do
        select OmniAuth::Strategies::DevAuth::NO_AUTH_EMAIL
        click_button 'Sign in'
      end

      it 'shows the forbidden page' do
        expect(page).to have_content 'Access to this service is restricted'
        expect(page).to have_http_status(:forbidden)
      end

      it 'uses the simplified error page' do
        expect(page).to have_no_css('nav.moj-primary-navigation')
        expect(page).to have_no_css('.govuk-notification-banner')
      end
    end

    context 'when an authorised, but not yet authenticated, user is selected' do
      let(:user) { User.create!(email: 'Zoe.Doe@example.com') }

      before do
        select user.email
        click_button 'Sign in'
      end

      it 'signs in the user' do
        expect(page).to have_content 'Zoe Doe'
        expect(page).to have_content 'Your list'
      end

      it 'guesses the name from the email' do
        expect(user.reload.name).to eq('Zoe Doe')
      end

      it 'sets the auth subject id' do
        expect(user.reload.auth_subject_id).not_to be_nil
      end
    end

    context 'when an authorised, authenticated, user is selected' do
      let(:auth_subject_id) { SecureRandom.uuid }
      let(:user) do
        User.create!(
          email: 'Zoe.Doe@example.com',
          last_name: 'Dowe',
          auth_subject_id: auth_subject_id
        )
      end

      before do
        select user.email
        click_button 'Sign in'
      end

      it 'signs in as the user' do
        expect(page).to have_content 'Zoe Dowe'
        expect(page).to have_content 'Your list'
      end

      it 'does not change user\'s name or auth_subject_id' do
        user_after_auth = user.reload
        expect(user_after_auth.name).to eq('Zoe Dowe')
        expect(user_after_auth.auth_subject_id).to eq(auth_subject_id)
      end
    end
  end
end
