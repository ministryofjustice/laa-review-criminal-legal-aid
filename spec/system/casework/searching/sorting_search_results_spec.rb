require 'rails_helper'

RSpec.describe 'Sorting search results' do
  include_context 'when search results are returned'
  let(:filter_field) { 'filter-application-status-field' }

  before do
    visit '/'
    click_link 'Search'
    click_button 'Search'
  end

  it_behaves_like 'a table with sortable headers' do
    let(:active_sort_headers) { ['Date received'] }
    let(:active_sort_direction) { 'ascending' }
    let(:inactive_sort_headers) { ['Applicant\'s name', 'Date closed'] }
  end

  describe 'Search results remain after sorting' do
    before do
      select 'Closed', from: filter_field
      click_button 'Search'
      click_on 'Date received'
    end

    it 'search filter remains applied' do
      expect(page).to have_select(filter_field, selected: 'Closed')
    end
  end
end
