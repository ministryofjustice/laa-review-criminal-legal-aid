require 'rails_helper'

RSpec.describe 'Downloading the Search Results' do
  include_context 'when search results are returned'

  before do
    click_button 'Search'
    click_button 'Download'
  end

  it 'downloads the expected search results as a csv file' do
    csv = page.driver.response.body
    expect(csv).to match(file_fixture('application_search.csv').read)
    expect(page.driver.response.content_type).to eq 'text/csv'
  end
end
