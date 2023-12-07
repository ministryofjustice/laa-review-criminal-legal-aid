require 'rails_helper'

RSpec.describe 'Unassign an application from myself' do
  include_context 'with stubbed search'

  before do
    visit '/'
    click_on 'Open applications'
    click_on('Kit Pound')
    click_on('Assign to your list')
    first(:button, 'Remove from your list').click
  end

  it 'the assigned application is unassigned' do
    expect(page).to have_content('Your list (0)')
  end

  it 'a success notice is shown' do
    expect(page).to have_content(
      'You removed the application from your list'
    )
  end
end
