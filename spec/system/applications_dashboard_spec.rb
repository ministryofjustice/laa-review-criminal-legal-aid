require 'rails_helper'

RSpec.describe 'Applications Dashboard' do
  before do
    visit '/'
    click_on 'All open applications'
  end

  it 'includes the page title' do
    expect(page).to have_content I18n.t('crime_applications.index.page_title')
  end

  it 'includes the correct headings' do
    column_headings = page.first('.app-dashboard-table thead tr').text

    expect(column_headings).to eq('Applicant Ref.no. Date received Time passed Common Platform Caseworker')
  end

  it 'shows the correct information' do
    first_row_text = page.first('.app-dashboard-table tbody tr').text
    days_ago = Rational((Time.zone.now - DateTime.parse('2022-10-27T14:09:11.000+00:00')), 1.day).floor
    expect(first_row_text).to eq("Kit Pound 120398120 27/10/2022 #{days_ago} days Yes")
  end

  it 'can be used to navigate to an application' do
    click_on('Kit Pound')

    expect(current_url).to match(
      'applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a'
    )
  end
end
