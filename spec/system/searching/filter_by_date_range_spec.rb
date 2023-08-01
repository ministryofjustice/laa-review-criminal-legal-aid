require 'rails_helper'

RSpec.describe 'Search by submitted date' do
  include_context 'with stubbed assignments and reviews'
  include_context 'when search results are returned'

  let(:after_date) { Date.parse('2023-06-08') }
  let(:before_date) { Date.parse('2023-01-09') }

  before do
    visit '/'
    click_link 'Search'

    fill_in 'Date from', with: after_date
    fill_in 'Date to', with: before_date

    click_button 'Search'
  end

  it 'searches by submitted date' do
    expect_datastore_to_have_been_searched_with(
      {
        submitted_before: '2023-01-09 00:00:00 +0000',
        submitted_after: '2023-06-08 00:00:00 +0100',
        review_status: Types::REVIEW_STATUS_GROUPS['open']
      }
    )
  end

  it 'remains selected on the results page' do
    expect(page).to have_field('Date from', with: after_date)
    expect(page).to have_field('Date to', with: before_date)
  end
end
