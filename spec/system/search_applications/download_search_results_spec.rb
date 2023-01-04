require 'rails_helper'

RSpec.describe 'Download Search Page' do
  include_context 'when search results are returned'

  before do
    click_button 'Search'
    click_button 'Download'
  end

  it 'downloads a csv of the search results' do
    csv = page.driver.response.body
    expect(csv).to match(file_fixture('application_search.csv').read)
  end
end
