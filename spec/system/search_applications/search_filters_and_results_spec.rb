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

  it 'includes the correct headings' do
    column_headings = page.first('.app-dashboard-table thead tr').text

    expect(column_headings).to eq('Applicant Ref. no. Date received Time passed Common Platform Caseworker Status')
  end
end
