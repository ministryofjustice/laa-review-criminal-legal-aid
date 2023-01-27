require 'rails_helper'

RSpec.describe 'Sorting search results' do
  include_context 'when search results are returned'

  before do
    visit '/'
    click_link 'Search'
    click_button 'Search'
  end

  describe 'sortable table headers' do
    describe 'Date received' do
      subject(:column_sort) do
        page.find('thead tr th#submitted_at')['aria-sort']
      end

      it 'is active and descending by default' do
        expect(column_sort).to eq 'descending'
      end

      context 'when clicked' do
        it 'changes to ascending when it is selected' do
          click_button 'Date received'
          expect(column_sort).to eq 'ascending'
        end
      end
    end
  end
end
