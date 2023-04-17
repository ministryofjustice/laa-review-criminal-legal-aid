require 'rails_helper'

RSpec.describe 'Unassign an application from myself' do
  include_context 'with stubbed search'

  before do
    visit '/'
    click_on 'All open applications'
    click_on('Kit Pound')
    click_on('Assign to your list')
    first(:button, 'Remove from your list').click
  end

  it 'the assigned application is unassigned' do
    expect(page).to have_content('Your list (0)')
  end

  it 'a success notice is shown' do
    expect(page).to have_content(
      'The application has been removed from your list'
    )
  end
end
