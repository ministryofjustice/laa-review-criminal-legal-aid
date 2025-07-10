require 'rails_helper'

RSpec.describe 'Copy text link' do
  include_context 'with an existing user'
  include_context 'with stubbed application'

  before do
    driven_by(:headless_chrome)
    visit '/'
    click_button 'Start now'
    click_button 'Sign in'
    visit crime_application_path(application_id)

    # Grant clipboard permissions in the browser context to allow JavaScript-based clipboard
    # interactions (e.g., copying or pasting text) during system tests.
    page.driver.browser.execute_cdp(
      'Browser.grantPermissions',
      origin: page.server_url,
      permissions: %w[clipboardReadWrite clipboardSanitizedWrite]
    )
  end

  describe 'clicking a copy link' do
    subject(:clipboard_text) { page.evaluate_async_script('navigator.clipboard.readText().then(arguments[0])') }

    let(:application_data) do
      super().deep_merge('case_details' => { 'urn' => '12AB3456789' })
    end

    it 'copies laa reference to clipboard' do
      laa_reference = find_by_id('reference-number').text
      click_on 'Copy LAA reference'

      expect(clipboard_text).to eq laa_reference
    end

    it 'copies unique reference number from overview section to clipboard' do
      urn = find_by_id('overview-urn').text
      click_link(id: 'copy-overview-urn')

      expect(clipboard_text).to eq urn
    end

    it 'copies unique reference number from case details section to clipboard' do
      urn = find_by_id('case-details-urn').text
      click_link(id: 'copy-case-details-urn')

      expect(clipboard_text).to eq urn
    end

    it 'copies date of birth to clipboard' do
      date_of_birth = find_by_id('date-of-birth').text
      click_link(id: 'copy-date-of-birth')

      expect(clipboard_text).to eq date_of_birth
    end

    it 'copies partner date of birth to clipboard' do
      date_of_birth = find_by_id('partner-date-of-birth').text
      click_link(id: 'copy-partner-date-of-birth')

      expect(clipboard_text).to eq date_of_birth
    end

    it 'copies nino to clipboard' do
      nino = find_by_id('nino').text
      click_link(id: 'copy-nino')

      expect(clipboard_text).to eq nino
    end

    it 'copies partner nino to clipboard' do
      nino = find_by_id('partner-nino').text
      click_link(id: 'copy-partner-nino')

      expect(clipboard_text).to eq nino
    end
  end
end
