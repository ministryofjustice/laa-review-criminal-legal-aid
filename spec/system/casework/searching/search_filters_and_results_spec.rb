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
    column_headings = page.all('.app-table thead tr th.govuk-table__header').map(&:text)

    expect(column_headings).to eq(
      ["Applicant's name", 'Reference number', 'Type of application', 'Case type', 'Date received', 'Date closed',
       'Closed by', 'Status']
    )
  end

  it 'shows the correct results' do
    first_row_text = page.first('.app-table tbody tr').text

    expect(first_row_text).to eq('Kit Pound 120398120 Initial Summary only 27 Oct 2022 Open')
  end

  it 'has the correct search results count' do
    expect(page).to have_content('3 search results')
  end

  context 'when navigating to an application via search' do
    it 'navigates to the application details tab for applications submitted once' do
      click_on('Kit Pound')

      expect(current_url).to match('applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a')
    end

    it 'navigates to the application history tab for resubmitted applications' do
      click_on('Jessica Rhode')

      expect(current_url).to match('applications/012a553f-e9b7-4e9a-a265-67682b572fd0/history')
    end
  end
end
