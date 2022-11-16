require 'rails_helper'

RSpec.describe 'Applications Dashboard' do
  before do
    visit '/applications'
  end

  it 'includes the page title' do
    expect(page).to have_content I18n.t('crime_applications.index.page_title')
  end

  it 'includes the correct headings' do
    column_headings = page.first('.app-dashboard-table thead tr').text

    expect(column_headings).to eq('Applicant Reference Date received Caseworker')
  end

  it 'shows the correct information' do
    first_row_text = page.first('.app-dashboard-table tbody tr').text
    expect(first_row_text).to eq('Kit Pound LAA-696dd4 27 Oct 2022')
  end

  it 'can be used to navigate to an application' do
    click_on('Kit Pound')

    expect(current_url).to match(
      'applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a'
    )
  end
end
