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

  describe 'clickling the link' do
    it 'copies the reference number to the system clipboard' do
      # get the reference reference number from the page
      case_reference = find('#reference-number').text

      # grant spec access to clipboard in headless chrome
      page.driver.browser.execute_cdp(
        'Browser.grantPermissions',
        origin: page.server_url,
        permissions: ['clipboardReadWrite']
      )

      # Click the link
      click_link 'Copy'

      # Get the current value of the clipboard
      # clipboard_value = page.evaluate_script('navigator.clipboard.readText()')
      clipboard_value = page.evaluate_async_script('navigator.clipboard.readText().then(arguments[0])')

      # Test the clipboard value against an expected value
      expect(clipboard_value).to eq case_reference
    end
  end
end
