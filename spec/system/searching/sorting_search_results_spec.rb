require 'rails_helper'

RSpec.describe 'Sorting search results' do
  include_context 'when search results are returned'
  let(:filter_field) { 'search-application-search-filter-application-status-field' }

  before do
    visit '/'
    click_link 'Search'
    click_button 'Search'
  end

  describe 'search by:' do
    describe 'default' do
      it 'filters by status "open"' do
        # TODO
        # replace with spec that asserts searched with sort when hooked up.
        click_button 'Date received'
        expect(page).to have_button('Date received')
      end
    end
  end
end
