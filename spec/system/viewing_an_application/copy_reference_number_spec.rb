require 'rails_helper'

RSpec.describe 'Reference number' do
  include_context 'with a logged in user'

  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  before do
    driven_by(:headless_chrome)
    visit '/'
    visit crime_application_path(application_id)
  end

  it 'has the copy link for the reference number' do
    expect(page).to have_content('Copy')
  end

  describe 'clicking the link' do
    it 'copies the reference number to the system clipboard' do
      case_reference = find_by_id('reference-number').text

      page.driver.browser.execute_cdp(
        'Browser.grantPermissions',
        origin: page.server_url,
        permissions: ['clipboardReadWrite']
      )

      click_link 'Copy'

      clipboard_value = page.evaluate_async_script('navigator.clipboard.readText().then(arguments[0])')

      expect(clipboard_value).to eq case_reference
    end
  end
end
