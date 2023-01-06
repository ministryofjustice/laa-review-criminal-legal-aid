require 'rails_helper'

RSpec.describe 'Closed Applications Dashboard' do
  before do
    visit '/'
    click_on 'Closed applications'
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
    expect(first_row_text).to eq('Ella Fitzgerald 5230234344 14/12/2022 14/12/2022 Returned')
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
