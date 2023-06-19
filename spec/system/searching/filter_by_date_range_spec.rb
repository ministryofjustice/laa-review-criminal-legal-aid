require 'rails_helper'

RSpec.describe 'Search by submitted date' do
  include_context 'when search results are returned'

  let(:after_date) { Date.parse('2023-06-08') }
  let(:before_date) { Date.parse('2023-01-09') }

  before do
    visit '/'
    click_link 'Search'

    fill_in 'filter-submitted-after-field', with: after_date
    fill_in 'filter-submitted-before-field', with: before_date

    click_button 'Search'
  end

  it 'searches by submitted date' do
    assert_api_searched_with_filter(
      :submitted_before, before_date,
      :submitted_after, after_date
    )
  end
end
