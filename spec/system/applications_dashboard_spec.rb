require 'rails_helper'

RSpec.describe 'Applications Dashboard' do
  include_context 'when applications exist'

  before do
    visit '/applications'
  end

  it 'includes the page title' do
    expect(page).to have_content I18n.t('crime_applications.index.page_title')
  end

  it 'includes the correct headings' do
    column_headings = page.first('.app-dashboard-table thead tr').text

    expect(column_headings).to eq('Applicant Reference Date received')
  end

  it 'shows the correct information' do
    first_row_text = page.first('.app-dashboard-table tbody tr').text
    expect(first_row_text).to eq('Zoe Wrong LAA-207a30 11 Oct 2022')
  end

  it 'can be used to navigate to an application' do
    click_on('Zoe Wrong')

    expect(current_url).to match('applications/207a30bd-d425-41d7-8665-75d93606cda6')
  end
end
