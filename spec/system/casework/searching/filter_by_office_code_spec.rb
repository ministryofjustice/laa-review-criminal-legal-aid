require 'rails_helper'

RSpec.describe 'Search applications office code filter' do
  include_context 'when search results are returned'
  let(:office_code_field) { 'filter-office-code-field' }
  let(:office_code) { '1A2BC3D' }

  before do
    visit '/'
    click_link 'Search'
    fill_in office_code_field, with: office_code
    click_button 'Search'
  end

  it 'searches by office code' do
    expect_datastore_to_have_been_searched_with(
      { office_code: office_code,
        review_status: Types::REVIEW_STATUS_GROUPS['all'] }
    )
  end

  it 'remains entered on the results page' do
    expect(page).to have_field(office_code_field, with: office_code)
  end
end
