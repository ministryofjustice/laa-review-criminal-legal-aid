require 'rails_helper'

RSpec.describe 'Search applications applicant date of birth filter' do
  include_context 'when search results are returned'
  let(:dob) { Date.parse('2011-06-09') }
  let(:date_of_birth_field) { 'filter-applicant-date-of-birth-field' }

  before do
    visit '/'

    click_on 'Search'
    fill_in date_of_birth_field, with: dob
    click_button 'Search'
  end

  it 'searches by applicant date of birth' do
    expect_datastore_to_have_been_searched_with({
                                                  applicant_date_of_birth: '2011-06-09',
      review_status: Types::REVIEW_STATUS_GROUPS['all']
                                                })
  end

  it 'remains selected on the results page' do
    expect(page).to have_field(date_of_birth_field, with: dob)
  end
end
