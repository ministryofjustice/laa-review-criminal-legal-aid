require 'rails_helper'

RSpec.describe 'Search applications status filter' do
  include_context 'when search results are returned'
  let(:filter_field) { 'filter-application-status-field' }

  before do
    visit '/'
    click_link 'Search'
  end

  it 'filters by "Open" by default' do
    expect(page).to have_select(filter_field, selected: 'Open')
  end

  it "can choose from 'Open', 'Completed', 'Sent back to provider' or 'All applications'" do
    choices = ['Open', 'Closed', 'Completed', 'Sent back to provider', 'All applications']
    expect(page).to have_select(filter_field, options: choices)
  end

  describe 'search by:' do
    describe 'default' do
      it 'filters by status "open"' do
        expect(page).to have_select(filter_field, selected: 'Open')
      end
    end

    describe 'Completed' do
      #
      # Completed is expected to raise an error because the completed
      # state is not yet supported.
      #
      # Here we catch the error and return an empty collection.
      #
      let(:datastore_response) do
        raise DatastoreApi::Errors::BadRequest
      end

      before do
        select 'Completed', from: filter_field
        click_button 'Search'
      end

      it 'filters by status "completed"' do
        expect(page).to have_select(filter_field, selected: 'Completed')
        expect(page).to have_content('There are no results that match the search criteria')
      end
    end

    describe 'Sent back to provider' do
      before do
        select 'Sent back to provider', from: filter_field
        click_button 'Search'
      end

      it 'filters by status "completed"' do
        assert_api_searched_with_filter(:application_status, 'sent_back')
        expect(page).to have_select(filter_field, selected: 'Sent back to provider')
      end
    end

    describe 'All applications' do
      before do
        select 'All applications', from: filter_field
        click_button 'Search'
      end

      it 'filters by all statuses"' do
        assert_api_searched_with_filter(:application_status, 'all')
        expect(page).to have_select(filter_field, selected: 'All applications')
      end
    end
  end
end
