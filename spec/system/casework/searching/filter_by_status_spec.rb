require 'rails_helper'

RSpec.describe 'Search applications status filter' do
  include_context 'when search results are returned'
  let(:filter_field) { 'filter-application-status-field' }

  before do
    visit '/'
    click_link 'Search'
  end

  it 'filters by "All" by default' do
    expect(page).to have_select(filter_field, selected: 'All applications')
  end

  it "can choose from 'Open', 'Completed', 'Sent back to provider' or 'All applications'" do
    choices = ['Open', 'Closed', 'Completed', 'Sent back to provider', 'All applications']
    expect(page).to have_select(filter_field, options: choices)
  end

  describe 'search by:' do
    describe 'default' do
      it 'filters by status "all"' do
        expect(page).to have_select(filter_field, selected: 'All applications')
      end
    end

    describe 'Sent back to provider' do
      before do
        select 'Sent back to provider', from: filter_field
        click_button 'Search'
      end

      it 'filters by status "completed"' do
        expect_datastore_to_have_been_searched_with(
          { review_status: Types::REVIEW_STATUS_GROUPS['sent_back'] }
        )
        expect(page).to have_select(filter_field, selected: 'Sent back to provider')
      end
    end

    describe 'All applications' do
      before do
        select 'All applications', from: filter_field
        click_button 'Search'
      end

      it 'filters by all statuses"' do
        expect_datastore_to_have_been_searched_with(
          { review_status: Types::REVIEW_STATUS_GROUPS['all'] }
        )
        expect(page).to have_select(filter_field, selected: 'All applications')
      end
    end
  end
end
