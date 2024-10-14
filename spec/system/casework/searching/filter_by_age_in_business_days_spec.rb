require 'rails_helper'

RSpec.describe 'Search applications by age in business days' do
  include_context 'with stubbed assignments and reviews'
  include_context 'when search results are returned'

  before do
    visit '/'
    click_link 'Search'
  end

  context 'when unassigned status is selected' do
    let(:age) { '0 days' }

    before do
      select age, from: 'Business days since application was received'
      click_button 'Search'
    end

    it 'passes the ids of applications of that age to the datastore search' do
      expect_datastore_to_have_been_searched_with(
        {
          application_id_in: unassigned_application_ids,
          review_status: Types::REVIEW_STATUS_GROUPS['all']
        }
      )
    end

    context 'when there are no applications of that age' do
      let(:age) { '1 day' }

      it 'returns an empty results set' do
        expect(page).to have_content 'There are no results that match the search criteria'
      end

      it 'does not search the datastore' do
        expect_datastore_not_to_have_been_searched
      end

      it '"1 day" remains selected on the results page' do
        expect(page).to have_select('Business days since application was received', selected: '1 day')
      end
    end
  end

  describe 'options for selecting assigned status' do
    it 'can choose from "", "0 days", "1 day", "2 days", "3 days"' do
      choices = ['', '0 days', '1 day', '2 days', '3 days']
      expect(page).to have_select('Business days since application was received', options: choices)
    end
  end
end
