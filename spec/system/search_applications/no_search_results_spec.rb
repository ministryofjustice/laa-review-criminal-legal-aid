require 'rails_helper'

RSpec.describe 'No search results' do
  include_context 'when search results empty'

  describe 'form help text' do
    it 'states that all fields are optional' do
      expect(page).to have_content('All fields are optional')
    end
  end

  describe 'no results found header' do
    it 'shows no results found message' do
      expect(page).to have_content('There are no results that match the search criteria')
    end
  end

  describe 'no results found list' do
    it 'shows no results found list' do
      expect(page).to have_content('Check the spelling of the applicant’s name')
      expect(page).to have_content('Make sure that you’ve entered the correct details')
    end
  end
end
