require 'rails_helper'

RSpec.describe 'Viewing your assigned application' do
  context 'when there are no assigned applications' do
    before do
      visit '/'
    end

    it 'includes the page title' do
      click_on 'Your list'
      expect(page).to have_content I18n.t('assigned_applications.index.page_title')
    end

    it 'shows shows how many assignments' do
      click_on 'Your list'
      expect(page).to have_content '0 saved applications'
    end
  end

  context 'when one application is assigned' do
    before do
      visit '/applications'
      click_on('Kit Pound')
      click_on('Assign to myself')
      visit '/applications'
      click_on('Your list')
    end

    it 'shows shows how many assignments' do
      expect(page).to have_content '1 saved application'
    end
  end

  context 'when multiple applications are assigned' do
    before do
      visit '/applications'
      click_on('Kit Pound')
      click_on('Assign to myself')
      visit '/applications'
      click_on('Don JONES')
      click_on('Assign to myself')
      visit '/applications'
      click_on('Your list')
    end

    it 'shows shows how many assignments' do
      expect(page).to have_content '2 saved application'
    end
  end
end
