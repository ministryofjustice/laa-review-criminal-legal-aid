require 'rails_helper'

RSpec.describe 'Viewing an application' do
  context 'when an application exists in the datastore' do
    before do
      visit '/'
      click_on 'All open applications'
      click_on('Kit Pound')
    end

    it 'includes the page title' do
      expect(page).to have_content I18n.t('crime_applications.show.page_title')
    end

    it 'includes the users details' do
      expect(page).to have_content('AJ123456C')
    end
  end

  context 'when an application does not exist in the datastore' do
    before do
      visit '/'
      visit '/applications/123'
    end

    it 'includes the page title' do
      expect(page).to have_content('Page not found')
    end
  end
end
