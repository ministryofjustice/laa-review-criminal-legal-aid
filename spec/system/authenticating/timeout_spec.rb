require 'rails_helper'

RSpec.describe 'Session timeout' do
  let(:timeout_in) do
    Rails.configuration.x.auth.timeout_in
  end

  before do
    freeze_time
    visit '/'
    travel(inactive_period)

    visit current_path
  end

  context 'when the inactive period is less than the limit' do
    let(:inactive_period) { timeout_in - 1.second }

    it 'the site can be accessed' do
      expect(page).to have_content 'Your list'
    end
  end

  context 'when the session times out' do
    let(:inactive_period) { timeout_in + 1.second }

    it 'signs the user out' do
      expect(page).to have_no_content 'Your list'
    end

    it 'shows the notification banner' do
      expect(page).to have_notification_banner(
        text: 'For your security, we signed you out',
        details: 'This is because you were inactive for 30 minutes.'
      )
    end
  end
end
