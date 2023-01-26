require 'rails_helper'

RSpec.describe 'Search applications applicant date of birth filter' do
  include_context 'when search results are returned'
  let(:dob) { Date.parse('2011-06-09') }

  before do
    visit '/'

    click_on 'Search'
    fill_in 'search-application-search-filter-applicant-date-of-birth-field', with: dob
    click_button 'Search'
  end

  it 'searches by applicant date of birth' do
    assert_api_searched_with_filter(:applicant_date_of_birth, dob)
  end

  it 'remains selected on the results page' do
    expect(page).to have_field(
      'search-application-search-filter-applicant-date-of-birth-field', with: dob
    )
  end
end
