require 'rails_helper'

RSpec.describe 'Search Page' do
  before do
    visit '/'
    click_on 'Search'
    click_button 'Search'
  end

  it 'includes the page title' do
    expect(page).to have_content('Search for an application')
  end

  it 'shows the application search input fields' do
    search_input_names = page.first('.search .govuk-fieldset .input-group').text

    expect(search_input_names).to eq("Reference number or applicant's first or last name\nApplicant's date of birth")
  end

  it 'shows the search criteria input fields' do
    search_input_names = page.all('.search .govuk-fieldset .input-group')[1].text

    expect(search_input_names).to eq("Date from\nDate to\nCaseworker Unassigned All assigned")
  end

  it 'includes the correct results table headings' do
    column_headings = page.first('.app-dashboard-table thead tr').text

    expect(column_headings).to eq('Applicant Ref. no. Date received Time passed Common Platform Caseworker Status')
  end

  it 'shows the correct results' do
    first_row_text = page.first('.app-dashboard-table tbody tr').text
    days_ago = Rational((Time.zone.now - DateTime.parse('2022-10-27T14:09:11.000+00:00')), 1.day).floor
    expect(first_row_text).to eq("Kit Pound 120398120 27/10/2022 #{days_ago} days Yes Open")
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
