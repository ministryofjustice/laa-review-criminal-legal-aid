require 'rails_helper'

RSpec.describe 'Open Applications Dashboard' do
  include_context 'with stubbed search'

  before do
    visit '/'
    click_on 'All open applications'
  end

  it 'includes the page title' do
    expect(page).to have_content I18n.t('casework.crime_applications.index.open_title')
  end

  it 'includes the correct headings' do
    column_headings = page.first('.app-dashboard-table thead tr').text.squish

    # rubocop:disable Layout/LineLength
    expect(column_headings).to eq("Applicant's name Reference number Date received Business days since application was received Caseworker")
    # rubocop:enable Layout/LineLength
  end

  it 'shows the correct information' do
    first_row_text = page.first('.app-dashboard-table tbody tr').text

    days_ago = Calendar.new.business_days_between(
      Date.parse('2022-10-27'), Time.current.in_time_zone('London')
    )

    expect(first_row_text).to eq("Kit Pound 120398120 27 Oct 2022 #{days_ago} days")
  end

  it 'receives the application if not already received' do
    returned_application = CrimeApplication.find(
      stubbed_search_results.first.resource_id
    )

    expect(returned_application.review_status).to be(:open)
  end

  it 'has the correct count' do
    expect(page).to have_content('There are 2 open applications that need to be reviewed.')
  end

  it 'can be used to navigate to an application' do
    click_on('Kit Pound')

    expect(current_url).to match(
      'applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a'
    )
  end

  it_behaves_like 'a table with sortable headers' do
    let(:active_sort_headers) { ['Date received', 'Business days since application was received'] }
    let(:active_sort_direction) { 'ascending' }
    let(:inactive_sort_headers) { ['Applicant\'s name'] }
  end
end
