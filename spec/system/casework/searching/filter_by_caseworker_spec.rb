require 'rails_helper'

RSpec.describe 'Search applications casewoker filter' do
  include_context 'when search results are returned'
  include_context 'with stubbed assignments and reviews'

  let(:stubbed_search_results) { [] }

  let(:assigned_status_field) { 'filter-assigned-status-field' }

  before do
    visit '/'

    click_link 'Search'
  end

  context 'when unassigned status is selected' do
    before do
      select 'Unassigned', from: assigned_status_field
      click_button 'Search'
    end

    it 'excludes assigned applications from the search' do
      expect_datastore_to_have_been_searched_with({
                                                    review_status: Types::REVIEW_STATUS_GROUPS['all'],
        application_id_in: unassigned_application_ids
                                                  })
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
      expect_datastore_to_have_been_searched_with({
                                                    review_status: Types::REVIEW_STATUS_GROUPS['all'],
        application_id_in: current_assignment_ids
                                                  })
    end

    it 'remains selected on the results page' do
      expect(page).to have_select(assigned_status_field, selected: 'All assigned')
    end
  end

  context 'when a user with assigned applications is selected' do
    before do
      select 'David Brown', from: assigned_status_field
      click_button 'Search'
    end

    it 'excludes unassigned applications from the search' do
      expect_datastore_to_have_been_searched_with({
                                                    review_status: Types::REVIEW_STATUS_GROUPS['all'],
        application_id_in: davids_applications
                                                  })
    end

    it 'remains selected on the results page' do
      expect(page).to have_select(assigned_status_field, selected: 'David Brown')
    end
  end

  describe 'options for selecting assigned status' do
    it 'can choose from "", "Unassigned", "All assigned", and caseworkers' do
      choices = ['', 'Unassigned', 'All assigned', 'David Brown', 'John Deere']
      expect(page).to have_select(assigned_status_field, options: choices)
    end
  end
end
