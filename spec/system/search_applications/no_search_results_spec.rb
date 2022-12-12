require 'rails_helper'

RSpec.describe 'No search results' do
  let(:dob) { Date.parse('21-02-1990') }

  before do
    visit '/'

    click_on 'Search'
  end

  describe 'no results found header' do
    before do
      fill_in 'filter-applicant-date-of-birth-field', with: dob
      click_button 'Search'
    end

    it 'shows no results found message' do
      expect(page).to have_content('There are no results that match the search criteria')
    end
  end

  describe 'no results found list' do
    before do
      fill_in 'filter-applicant-date-of-birth-field', with: dob
      click_button 'Search'
    end

    it 'shows no results found list' do
      expect(page).to have_content('Check the spelling of the applicant’s name')
      expect(page).to have_content('Make sure that you’ve entered the correct details')
    end
  end
end
