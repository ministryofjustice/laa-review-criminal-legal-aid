require 'rails_helper'

RSpec.describe 'Search applications status filter' do
  include_context 'when search results are returned'
  let(:filter_field) { 'filter-application-status-field' }

  before do
    visit '/'
    click_on 'Search'
  end

  it 'filters by "Open" by default' do
    expect(page).to have_select(filter_field, selected: 'Open')
  end

  it "can choose from 'Open', 'Completed', 'Sent back to provider' or 'All applications'" do
    choices = ['Open', 'Completed', 'Sent back to provider', 'All applications']
    expect(page).to have_select(filter_field, options: choices)
  end

  describe 'search by:' do
    describe 'default' do
      it 'filters by status "open"' do
        click_button 'Search'
        assert_api_searched_with_filter(:application_status, 'open')
        expect(page).to have_select(filter_field, selected: 'Open')
      end
    end

    describe 'Completed' do
      before do
        select 'Completed', from: filter_field
        click_button 'Search'
      end

      it 'filters by status "completed"' do
        assert_api_searched_with_filter(:application_status, 'completed')
        expect(page).to have_select(filter_field, selected: 'Completed')
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
