require 'rails_helper'

RSpec.describe 'Search Page' do
  include_context 'when search results are returned'
  before do
    visit '/'
    click_link 'Search'
    click_button 'Search'
  end

  it 'includes the page title' do
    expect(page).to have_content('Search for an application')
  end

  it 'shows the application search input fields' do
    search_input_names = page.first('.search .govuk-fieldset .input-group').text

    expect(search_input_names).to eq("Reference number or applicant's first or last name\nApplicant's date of birth")
  end

  it 'includes the correct results table headings' do
    column_headings = page.first('.app-dashboard-table thead tr').text.squish

    expect(column_headings).to eq(
      "Applicant's name Reference number Date received Date closed Caseworker Status"
    )
  end

  it 'shows the correct results' do
    first_row_text = page.first('.app-dashboard-table tbody tr').text

    expect(first_row_text).to eq('Kit Pound 120398120 27 Oct 2022 Open')
  end

  it 'has the correct search results count' do
    expect(page).to have_content('2 search results')
  end

  it 'can be used to navigate to an application' do
    click_on('Kit Pound')

    expect(current_url).to match(
      'applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a'
    )
  end
end
