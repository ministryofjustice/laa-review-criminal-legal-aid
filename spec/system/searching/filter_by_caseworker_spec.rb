require 'rails_helper'

RSpec.describe 'Search applications casewoker filter' do
  include_context 'when search results are returned'
  let(:assigned_status_field) { 'search-application-search-filter-assigned-status-field' }

  before do
    visit '/'

    user_id = User.last.id
    Assigning::AssignToUser.new(
      assignment_id: SecureRandom.uuid, user_id: user_id, to_whom_id: user_id
    ).call

    click_link 'Search'
  end

  context 'when unassigned status is selected' do
    before do
      select 'Unassigned', from: assigned_status_field
      click_button 'Search'
    end

    it 'excludes assigned applications from the search' do
      assert_api_searched_with_filter(
        :assigned_status, 'unassigned'
      )
    end

    it 'remains selected on the results page' do
      expect(page).to have_select(assigned_status_field, selected: 'Unassigned')
    end
  end

  context 'when assigned status is selected' do
    before do
      select 'All assigned', from: assigned_status_field
      click_button 'Search'
    end

    it 'excludes unassigned applications from the search' do
      assert_api_searched_with_filter(
        :assigned_status, 'assigned'
      )
    end

    it 'remains selected on the results page' do
      expect(page).to have_select(assigned_status_field, selected: 'All assigned')
    end
  end

  describe 'options for selecting assigned status' do
    it 'can choose from "", "Unassigned", "All assigned", and caseworkers' do
      choices = ['', 'Unassigned', 'All assigned', 'Joe EXAMPLE']
      expect(page).to have_select(assigned_status_field, options: choices)
    end
  end
end
