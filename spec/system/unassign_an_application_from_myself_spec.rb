require 'rails_helper'

RSpec.describe 'Unassign an application from myself' do
  before do
    visit '/'
    click_on 'All open applications'
    click_on('Kit Pound')
    click_on('Assign to myself')
    click_on('Remove from your list')
  end

  it 'the assigned application is unassigned' do
    expect(page).to have_content(
      '0 saved applications'
    )
  end

  it 'a success notice is shown' do
    expect(page).to have_content(
      'The application has been removed from your list'
    )
  end
end
