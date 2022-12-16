require 'rails_helper'

RSpec.describe 'Sub navigation' do
  before do
    visit '/'
    click_on 'All open applications'
    click_on('Kit Pound')
  end

  context 'with the "Application details" link' do
    it 'takes the user to their list when clicked' do
      click_on('Application details')

      heading_text = page.first('.govuk-heading-xl').text

      expect(heading_text).to eq('Kit Pound')
    end
  end

  context 'when the "Application history" link' do
    it 'links to the application history page' do
      expect { click_on('Application history') }.to change(page, :current_path).from(
        '/applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a'
      ).to(
        '/applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a/history'
      )
    end
  end
end
