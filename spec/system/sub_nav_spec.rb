require 'rails_helper'

RSpec.describe 'Sub navigation' do
  before do
    visit '/applications'
    click_on('Kit Pound')
  end

  context 'with the "Application details" link' do
    it 'takes the user to their list when clicked' do
      click_on('Application details')

      heading_text = page.first('.govuk-heading-l').text

      expect(heading_text).to eq('Kit Pound')
    end
  end
end
