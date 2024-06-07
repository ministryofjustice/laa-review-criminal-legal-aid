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
      expect(page).to have_no_content 'Your list'
    end

    it 'shows the notification banner' do
      expect(page).to have_notification_banner(
        text: 'For your security, we signed you out',
        details: 'This is because you were signed in for more than 12 hours.'
      )
    end
  end
end
