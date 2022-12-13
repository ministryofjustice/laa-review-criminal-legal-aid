require 'rails_helper'

RSpec.describe 'Assigning an application to myself' do
  it 'allows you to get the next application' do
    visit '/'
    click_on 'Get next application'
    expect(page).to have_content('Kit Pound')
    expect(page).to have_content('This application has been assigned to you')
  end

  # rubocop:disable RSpec/ExampleLength
  it 'shows an error when there is no next application' do
    visit '/'
    click_on 'Get next application'
    visit '/'
    click_on 'Get next application'
    visit '/'
    click_on 'Get next application'
    expect(page).to have_content('Your list')
    expect(page).to have_content('There are no unassigned applications to that need processing at this time')
  end
  # rubocop:enable RSpec/ExampleLength
end
