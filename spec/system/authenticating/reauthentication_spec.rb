require 'rails_helper'

RSpec.describe 'Reauthentication' do
  let(:reauthenticate_in) do
    Rails.configuration.x.auth.reauthenticate_in
  end

  before do
    visit '/'
    current_user.update(last_auth_at:)
    visit current_path
  end

  context 'when the authentication has not expired' do
    let(:last_auth_at) { (reauthenticate_in - 1.second).ago }

    it 'the site can be accessed' do
      expect(page).to have_content 'Your list'
    end
  end

  context 'when the authentication has expired' do
    let(:last_auth_at) { (reauthenticate_in + 1.second).ago }

    it 'signs the user out' do
      expect(page).not_to have_content 'Your list'
    end

    it 'shows the correct title' do
      expect(page).to have_css('h1.govuk-heading-xl', text: 'For your security, we signed you out')
    end

    it 'shows the correct body' do
      expect(page).to have_css('p.govuk-body', text: 'This is becasue you were signed in for more than 12 hours.')
      expect(page).to have_css('p.govuk-body', text: 'Sign in again to continue using the service.')
    end

    it 'shows the sign in button' do
      expect(page).to have_button('Sign in')
    end
  end
end
