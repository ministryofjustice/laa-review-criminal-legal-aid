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
       'Caseworker', 'Status']
    )
  end

  it 'shows the correct results' do
    first_row_text = page.first('.app-table tbody tr').text

    expect(first_row_text).to eq(
      'Kit Pound 120398120 Initial Summary only 27 Oct 2022 ' \
      'No data exists for Date closed No data exists for Caseworker Open'
    )
  end

  context 'when result is PSE' do
    let(:stubbed_search_results) do
      [
        ApplicationSearchResult.new(
          applicant_name: 'Kit Pound',
          resource_id: '21c37e3e-520f-46f1-bd1f-5c25ffc57d70',
          reference: 120_398_120,
          status: 'submitted',
          work_stream: 'criminal_applications_team',
          submitted_at: '2022-10-24T09:50:04.019Z',
          parent_id: '696dd4fd-b619-4637-ab42-a5f4565bcf4a',
          application_type: 'post_submission_evidence'
        )
      ]
    end

    it 'shows the correct results' do
      first_row_text = page.first('.app-table tbody tr').text

      expect(first_row_text).to eq(
        'Kit Pound 120398120 Post submission evidence No data exists for Case type ' \
        '24 Oct 2022 No data exists for Date closed No data exists for Caseworker Open'
      )
    end
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
