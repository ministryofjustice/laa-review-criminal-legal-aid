require 'rails_helper'

RSpec.describe 'Search applications casewoker filter' do
  include_context 'when search results are returned'

  context 'when unassigned status is selected' do
    before do
      select 'Unassigned', from: 'filter-assigned-status-field'
      click_button 'Search'
    end

    it 'excludes assigned applications from the search' do
      assert_api_searched_with_filter(
        :assigned_status, 'unassigned'
      )
    end

    it 'remains selected on the results page' do
      expect(page).to have_select(
        'filter-assigned-status-field', selected: 'Unassigned'
      )
    end
  end

  context 'when assigned status is selected' do
    before do
      select 'All assigned', from: 'filter-assigned-status-field'
      click_button 'Search'
    end

    it 'excludes unassigned applications from the search' do
      assert_api_searched_with_filter(
        :assigned_status, 'assigned'
      )
    end

    it 'remains selected on the results page' do
      expect(page).to have_select(
        'filter-assigned-status-field', selected: 'All assigned'
      )
    end
  end

  describe 'options for selecting assigned status' do
    before do
      visit '/'
      click_on 'Search'
    end

    it 'can choose from "", "Unassigned", "All assigned", and caseworkers' do
      choices = ['', 'Unassigned', 'All assigned', 'Joe EXAMPLE']
      expect(page).to have_select('filter-assigned-status-field', options: choices)
    end
  end
end
