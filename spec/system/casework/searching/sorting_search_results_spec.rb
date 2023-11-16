require 'rails_helper'

RSpec.describe 'Sorting search results' do
  include_context 'when search results are returned'

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
end
