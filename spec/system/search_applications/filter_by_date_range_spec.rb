require 'rails_helper'

RSpec.describe 'Search applications casewoker filter' do
  let(:application_date) { Date.parse('27-10-2022') }

  before do
    visit '/'

    click_on 'Search'
  end

  describe 'by default' do
    before do
      click_button 'Search'
    end

    it 'shows all applications' do
      expect(page).to have_content('2 search results')
    end
  end

  describe 'with "Date from" constraint' do
    it 'shows applcations submitted on Date from' do
      fill_in 'filter-start-on-field', with: application_date
      click_button 'Search'

      expect(page).to have_content('2 search results')
      expect(page).to have_content('Kit Pound')
    end

    it 'omits applcations submitted before Date from' do
      fill_in 'filter-start-on-field', with: (application_date + 1.day)
      click_button 'Search'

      expect(page).to have_content('1 search result')
      expect(page).not_to have_content('Kit Pound')
    end
  end

  describe 'with "Date to" constraint' do
    it 'shows applcations submitted on Date to' do
      fill_in 'filter-end-on-field', with: application_date
      click_button 'Search'

      expect(page).to have_content('1 search result')
      expect(page).to have_content('Kit Pound')
    end

    it 'omits applcations submitted before Date from' do
      fill_in 'filter-end-on-field', with: (application_date - 1.day)
      click_button 'Search'

      expect(page).to have_content('There are no results that match the search criteria')
      expect(page).not_to have_content('Kit Pound')
    end
  end
end
