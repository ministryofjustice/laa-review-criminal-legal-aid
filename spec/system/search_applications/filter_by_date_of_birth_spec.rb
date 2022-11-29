require 'rails_helper'

RSpec.describe 'Search applications applicant date of birth filter' do
  let(:dob) { Date.parse('2011-06-09') }

  before do
    visit '/'

    click_on 'All open applications'
    fill_in 'filter-applicant-date-of-birth-field', with: dob
    click_on 'Search'
  end

  it 'returns applications with the specified DOB' do
    expect(page).to have_content('1 search result')
    expect(page).to have_content('Kit Pound')
  end
end
