require 'rails_helper'

RSpec.describe 'Manage Users Dashboard' do
  include_context 'with a logged in user'

  before do
    visit '/'
    visit '/admin/manage_users'
  end

  it 'includes the page heading' do
    expect(page).to have_content 'Manage users'
  end

  # it 'includes the button to add new user' do
  #   expect(page).to have_content 'Add new user'
  # end
  #
  # it 'includes the correct headings' do
  #   column_headings = page.first('.app-manage-users-table thead tr').text.squish
  #
  #   expect(column_headings).to eq('Email Manage other users Actions')
  # end
  #
  # it 'shows the correct information' do
  #   expect(page).to have_content('Joe.EXAMPLE@justice.gov.uk')
  # end
end
