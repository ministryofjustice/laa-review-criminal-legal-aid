require 'rails_helper'

RSpec.describe 'Closed Applications Dashboard' do
  include_context 'with stubbed search'

  let(:stubbed_search_results) do
    [
      ApplicationSearchResult.new(
        applicant_name: 'Ella Fitzgerald',
        resource_id: '5aa4c689-6fb5-47ff-9567-5efe7f8ac211',
        reference: 5_230_234_344,
        status: 'returned',
        submitted_at: '2022-12-14T16:58:15.000+00:00',
        reviewed_at: '2022-12-15T16:58:15.000+00:00'
      )
    ]
  end

  before do
    visit '/'
    click_on 'Closed applications'
  end

  it 'shows only closed applications' do
    assert_api_searched_with_filter(status: 'sent_back')
  end

  it 'includes the page title' do
    expect(page).to have_content I18n.t('crime_applications.index.closed_title')
  end

  it 'includes the correct headings' do
    column_headings = page.first('.app-dashboard-table thead tr').text

    expect(column_headings).to eq('Applicant Ref. no. Date received Date reviewed Reviewed by Status')
  end

  it 'shows the correct information' do
    first_row_text = page.first('.app-dashboard-table tbody tr').text
    expect(first_row_text).to eq('Ella Fitzgerald 5230234344 14/12/2022 15/12/2022 Returned')
  end

  it 'has the correct count' do
    expect(page).to have_content('1 application')
  end

  it 'can be used to navigate to an application' do
    click_on('Ella Fitzgerald')

    expect(current_url).to match(
      'applications/5aa4c689-6fb5-47ff-9567-5efe7f8ac211'
    )
  end
end
